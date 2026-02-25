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
    var customStartDate: Date
    var customEndDate: Date

    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [TaskModel]
    @State private var searchText = ""
    @State private var currentSort: TaskSort = .dateAscending
    @State private var showingAddTask = false

    init(filter: TaskFilter, customStartDate: Date = Date(), customEndDate: Date = Date().addingTimeInterval(86400 * 14)) {
        self.filter = filter
        self.customStartDate = customStartDate
        self.customEndDate = customEndDate
        _allTasks = Query(sort: [SortDescriptor(\TaskModel.date, order: .forward), SortDescriptor(\TaskModel.createdDate, order: .forward)])
    }

    private var filteredTasks: [TaskModel] {
        var tasks = allTasks.filter { !$0.isDeleted }

        switch filter {
        case .all:
            tasks = tasks.filter { !$0.isCompleted }
        case .today:
            let start = Date().startOfDay
            let end = Date().endOfDay
            tasks = tasks.filter { !$0.isCompleted && $0.date != nil && $0.date! >= start && $0.date! <= end }
        case .tomorrow:
            let start = Date.tomorrow.startOfDay
            let end = Date.tomorrow.endOfDay
            tasks = tasks.filter { !$0.isCompleted && $0.date != nil && $0.date! >= start && $0.date! <= end }
        case .week:
            let start = Date().startOfDay
            let end = Date.nextWeek.endOfDay
            tasks = tasks.filter { !$0.isCompleted && $0.date != nil && $0.date! >= start && $0.date! <= end }
        case .custom:
            let start = customStartDate.startOfDay
            let end = customEndDate.endOfDay
            tasks = tasks.filter { !$0.isCompleted && $0.date != nil && $0.date! >= start && $0.date! <= end }
        case .completed:
            tasks = tasks.filter { $0.isCompleted }
        }

        if !searchText.isEmpty {
            tasks = tasks.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }

        return tasks.sorted(using: currentSort)
    }

    var body: some View {
        List {
            ForEach(filteredTasks) { task in
                TaskRowView(task: task)
            }
            .onDelete(perform: deleteTasks)
        }
        .searchable(text: $searchText, prompt: String(localized: "searchPlaceholder", defaultValue: "Search"))
        .navigationTitle(filter.displayName)
        .overlay {
            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? String(localized: "noTasks", defaultValue: "No tasks") : String(localized: "noSearchResults", defaultValue: "No results"),
                    systemImage: searchText.isEmpty ? "checklist" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "" : String(localized: "tryDifferentSearch", defaultValue: "Try a different search term"))
                )
            }
        }
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
                    Label(String(localized: "sort", defaultValue: "Sort"), systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            if filter != .completed {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .frame(width: 56, height: 56)
                }
                .glassEffect(.regular.interactive())
                .padding()
            }
        }
        .sheet(isPresented: $showingAddTask) {
            TaskEditView()
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
        TaskListView(filter: .all)
    }
    .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
