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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
        } else if #available(iOS 27, *), horizontalSizeClass == .regular {
            taskColumnsContent
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

    @available(iOS 27, *)
    private var taskColumnsContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 17) {
                if filter == .upcoming {
                    ForEach(groupedByDay, id: \.0) { day, tasks in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(day.formatted(style: .sectionHeader))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, EdgeInsets.columnCell.leading)
                                .padding(.vertical, 10)
                            taskColumns(tasks)
                        }
                    }
                } else {
                    taskColumns(filteredTasks)
                }
            }
            .padding(.bottom, 20)
        }
        .columnsScrollMargins()
        .swipeActionsContainer()
        .background(Color(.systemGroupedBackground))
    }

    @available(iOS 27, *)
    @ViewBuilder
    private func taskColumns(_ tasks: [TaskModel]) -> some View {
        let positions = Dictionary(uniqueKeysWithValues: tasks.enumerated().map { ($1.id, $0) })
        if filter != .upcoming && currentSort == .manual {
            ColumnsLayout {
                ForEach(tasks) { taskCell($0, position: positions[$0.id] ?? 0, count: tasks.count) }
                    .reorderable()
            }
            .reorderContainer(for: TaskModel.self) { reorderTasks($0) }
            .columnsPanel()
        } else {
            ColumnsLayout {
                ForEach(tasks) { taskCell($0, position: positions[$0.id] ?? 0, count: tasks.count) }
            }
            .columnsPanel()
        }
    }

    @available(iOS 27, *)
    private func taskCell(_ task: TaskModel, position: Int, count: Int) -> some View {
        TaskRowView(task: task, insets: .columnCell)
            .columnCell(position: position, count: count, separatorLeading: 66)
            .swipeActions {
                Button(role: .destructive) {
                    task.isDeleted = true
                } label: {
                    Label(String(localized: "delete", defaultValue: "Delete"), systemImage: "trash")
                }
            }
            .clipped()
    }

    @available(iOS 27, *)
    private func reorderTasks(_ difference: ReorderDifference<TaskModel.ID, ReorderableSingleCollectionIdentifier>) {
        let moving = Set(difference.sources)
        var tasks = filteredTasks.filter { !moving.contains($0.id) }
        let moved = filteredTasks.filter { moving.contains($0.id) }

        switch difference.destination.position {
        case .before(let id):
            tasks.insert(contentsOf: moved, at: tasks.firstIndex { $0.id == id } ?? tasks.endIndex)
        case .end:
            tasks.append(contentsOf: moved)
        }

        for (index, task) in tasks.enumerated() {
            task.sortOrder = index
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
