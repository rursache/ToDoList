//
//  TaskListView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    let filter: TaskFilter

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query private var allTasks: [TaskModel]
    @State private var showingAddTask = false

    init(filter: TaskFilter) {
        self.filter = filter
        _allTasks = Query(sort: [SortDescriptor(\TaskModel.date, order: .forward), SortDescriptor(\TaskModel.createdDate, order: .forward)])
    }

    private var currentSort: TaskSort {
        TaskSort(rawValue: appSettings.taskSort) ?? .dateAscending
    }

    private var filteredTasks: [TaskModel] {
        var tasks = allTasks.filter { !$0.isDeleted }

        switch filter {
        case .inbox:
            tasks = tasks.filter { !$0.isCompleted }
        case .today:
            let start = Date().startOfDay
            let end = Date().endOfDay
            tasks = tasks.filter { !$0.isCompleted && $0.date != nil && $0.date! >= start && $0.date! <= end }
        case .upcoming:
            let start = Date().startOfDay
            tasks = tasks.filter { !$0.isCompleted && $0.date != nil && $0.date! >= start }
        case .completed:
            tasks = tasks.filter { $0.isCompleted }
        }

        return tasks.sorted(using: currentSort)
    }

    var body: some View {
        taskListContent
            .contentMargins(.top, 6, for: .scrollContent)
            .navigationTitle(filter.displayName)
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar(filter == .completed ? .hidden : .automatic, for: .tabBar)
            .toolbar {
                if filter != .completed {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            TaskListView(filter: .completed)
                        } label: {
                            Image(systemName: "checkmark.circle")
                        }
                        .accessibilityLabel(TaskFilter.completed.displayName)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
                if filter != .completed {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        addTaskButton
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskEditView(defaultDate: filter == TaskFilter.today ? Date() : nil)
            }
    }

    @ViewBuilder
    private var taskListContent: some View {
        if filteredTasks.isEmpty {
            emptyStateView
        } else if filter == .upcoming {
            List {
                ForEach(groupedByDay, id: \.0) { day, tasks in
                    Section {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                tasks[index].isDeleted = true
                            }
                        }
                    } header: {
                        Text(day.formatted(style: .sectionHeader))
                    }
                }
            }
        } else {
            List {
                ForEach(filteredTasks) {
                    TaskRowView(task: $0)
                }
                .onDelete(perform: deleteTasks)
                .onMove(perform: moveTasks)
                .moveDisabled(currentSort != .manual)
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(TaskSort.allCases) { sort in
                Button {
                    appSettings.taskSort = sort.rawValue
                } label: {
                    if sort == currentSort {
                        Label(sort.displayName, systemImage: "checkmark")
                    } else {
                        Text(sort.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .imageScale(.medium)
        }
        .accessibilityLabel("Sort")
        .accessibilityValue(currentSort.displayName)
    }

    private var addTaskButton: some View {
        Button {
            showingAddTask = true
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(.white.opacity(0.8))
                .font(.callout)
                .fontWeight(.semibold)
        }
        .accessibilityLabel("Add new task")
        .glassEffect(.clear.tint(appSettings.theme.color).interactive(), in: .circle)
        .scaleEffect(1.2)
    }

    private var groupedByDay: [(Date, [TaskModel])] {
        let grouped = Dictionary(grouping: filteredTasks) { task in
            (task.date ?? task.createdDate).startOfDay
        }
        return grouped.sorted { $0.key < $1.key }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(filter.emptyTitle, systemImage: filter.emptySystemImage)
        } description: {
            Text(filter.emptyDescription)
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            task.isDeleted = true
        }
    }

    private func moveTasks(from source: IndexSet, to destination: Int) {
        var tasks = filteredTasks
        tasks.move(fromOffsets: source, toOffset: destination)
        for (index, task) in tasks.enumerated() {
            task.sortOrder = index
        }
    }
}

#Preview {
    NavigationStack {
        TaskListView(filter: .inbox)
    }
    .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
