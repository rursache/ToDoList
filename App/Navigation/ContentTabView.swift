//
//  ContentTabView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData

struct ContentTabView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        TabView {
            Tab(String(localized: "tabToday", defaultValue: "Today"), systemImage: "sun.max") {
                NavigationStack {
                    TaskListView(filter: .today)
                }
            }

            Tab(String(localized: "tabAll", defaultValue: "All"), systemImage: "tray") {
                NavigationStack {
                    TaskListView(filter: .all)
                }
            }

            Tab(String(localized: "tabUpcoming", defaultValue: "Upcoming"), systemImage: "calendar") {
                NavigationStack {
                    UpcomingTasksView()
                }
            }

            Tab(String(localized: "tabCompleted", defaultValue: "Completed"), systemImage: "checkmark.circle") {
                NavigationStack {
                    TaskListView(filter: .completed)
                }
            }

            Tab(String(localized: "tabSettings", defaultValue: "Settings"), systemImage: "gear") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
    }

    @ViewBuilder
    static var defaultDetailView: some View {
        TaskListView(filter: .today)
    }
}
