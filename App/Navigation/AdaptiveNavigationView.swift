//
//  AdaptiveNavigationView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct AdaptiveNavigationView: View {
    @State private var selectedFilter: TaskFilter? = .inbox

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView {
                List(sidebarFilters, selection: $selectedFilter) { filter in
                    Label(filter.displayName, systemImage: filter.systemImage)
                }
                .navigationTitle("ToDoList")
            } detail: {
                if let filter = selectedFilter {
                    TaskListView(filter: filter)
                } else {
                    ContentUnavailableView(
                        String(localized: "selectCategory", defaultValue: "Select a category"),
                        systemImage: "sidebar.left"
                    )
                }
            }
        } else {
            ContentTabView()
        }
    }

    private var sidebarFilters: [TaskFilter] {
        [.inbox, .today, .upcoming, .completed]
    }
}

#Preview {
    AdaptiveNavigationView()
        .modelContainer(DatabaseConfiguration.makePreviewContainer())
}
