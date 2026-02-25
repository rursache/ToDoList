//
//  SearchView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allTasks: [TaskModel]
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredTasks: [TaskModel] {
        guard !searchText.isEmpty else { return [] }
        return allTasks
            .filter { !$0.isDeleted }
            .filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if searchText.isEmpty {
                ContentUnavailableView(
                    String(localized: "searchTasks", defaultValue: "Search Tasks"),
                    systemImage: "magnifyingglass",
                    description: Text(String(localized: "searchDescription", defaultValue: "Search across all your tasks"))
                )
            } else if filteredTasks.isEmpty {
                ContentUnavailableView(
                    String(localized: "noSearchResults", defaultValue: "No Results"),
                    systemImage: "magnifyingglass",
                    description: Text(String(localized: "noSearchResultsDescription", defaultValue: "No tasks match \"\(searchText)\""))
                )
            } else {
                List {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task)
                    }
                }
            }
        }
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(String(localized: "search", defaultValue: "Search"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .fixedSize()
            }
        }
        .searchable(text: $searchText, prompt: String(localized: "searchPlaceholder", defaultValue: "Search tasks..."))
        .searchFocused($isSearchFocused)
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .onAppear {
            isSearchFocused = true
        }
    }
}
