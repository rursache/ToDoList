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
    @State private var currentSort: TaskSort = .dateAscending
    @State private var showingAddTask = false

    init(filter: TaskFilter) {
        self.filter = filter
        _allTasks = Query(sort: [SortDescriptor(\TaskModel.date, order: .forward), SortDescriptor(\TaskModel.createdDate, order: .forward)])
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
        Group {
            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    String(localized: "noTasks", defaultValue: "No tasks"),
                    systemImage: "checklist"
                )
            } else {
                List {
                    ForEach(filteredTasks) {
                        TaskRowView(task: $0)
                    }.onDelete(perform: deleteTasks)
                }
            }
        }
        .contentMargins(.top, 6, for: .scrollContent)
        .navigationTitle(filter.displayName)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(TaskSort.allCases) { sort in
                        Button {
                            currentSort = sort
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
            }

            if filter != .completed {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .glassEffect(.clear.tint(appSettings.theme.color).interactive(), in: .circle)
                    .scaleEffect(1.2)
                }.sharedBackgroundVisibility(.hidden)
            }
        }
        .sheet(isPresented: $showingAddTask) {
            TaskEditView(defaultDate: filter == TaskFilter.today ? Date() : nil)
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            task.isDeleted = true
        }
    }
}

#Preview {
    NavigationStack {
        TaskListView(filter: .inbox)
    }
    .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
