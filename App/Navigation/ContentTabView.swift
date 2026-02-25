//
//  ContentTabView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData

struct ContentTabView: View {
    enum TabSelection: Int {
        case inbox
        case today
        case upcoming
        case settings
        case search
    }

    @Environment(AppSettings.self) private var appSettings
    @State private var selectedTab: TabSelection

    init() {
        let page = AppSettings.shared.startPage
        switch page {
        case 0: _selectedTab = State(initialValue: .inbox)
        case 2: _selectedTab = State(initialValue: .upcoming)
        default: _selectedTab = State(initialValue: .today)
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: "tabInbox", defaultValue: "Inbox"), systemImage: "tray", value: .inbox) {
                NavigationStack {
                    TaskListView(filter: .inbox)
                }
            }

            Tab(String(localized: "tabToday", defaultValue: "Today"), systemImage: "sun.max", value: .today) {
                NavigationStack {
                    TaskListView(filter: .today)
                }
            }

            Tab(String(localized: "tabUpcoming", defaultValue: "Upcoming"), systemImage: "calendar", value: .upcoming) {
                NavigationStack {
                    TaskListView(filter: .upcoming)
                }
            }

            Tab(String(localized: "tabSettings", defaultValue: "Settings"), systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }

            Tab(value: TabSelection.search, role: .search) {
                SearchView()
            }
        }
    }
}
