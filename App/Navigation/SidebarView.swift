//
//  SidebarView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedFilter: TaskFilter? = .today

    private var sidebarFilters: [TaskFilter] {
        [.today, .all, .tomorrow, .week, .completed]
    }

    var body: some View {
        List(sidebarFilters, selection: $selectedFilter) { filter in
            NavigationLink(value: filter) {
                Label(filter.displayName, systemImage: filter.systemImage)
            }
        }
        .navigationTitle("ToDoList")
    }
}
