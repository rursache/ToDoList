//
//  SidebarView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedFilter: TaskFilter? = .inbox

    private var sidebarFilters: [TaskFilter] {
        [.inbox, .today, .upcoming, .completed]
    }

    var body: some View {
        List(sidebarFilters, selection: $selectedFilter) { filter in
            NavigationLink(value: filter) {
                Label(filter.displayName, systemImage: filter.systemImage)
            }
        }
        .navigationTitle(AppSettings.appName)
    }
}

#Preview {
    NavigationStack {
        SidebarView()
    }
}
