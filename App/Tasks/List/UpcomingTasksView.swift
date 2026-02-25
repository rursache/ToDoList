//
//  UpcomingTasksView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct UpcomingTasksView: View {
    @State private var selectedScope: UpcomingScope = .tomorrow
    @State private var customStartDate = Date()
    @State private var customEndDate = Date().addingTimeInterval(86400 * 14)

    enum UpcomingScope: String, CaseIterable, Identifiable {
        case tomorrow
        case week
        case custom

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .tomorrow: String(localized: "filterTomorrow", defaultValue: "Tomorrow")
            case .week: String(localized: "filterWeek", defaultValue: "Next 7 Days")
            case .custom: String(localized: "filterCustom", defaultValue: "Custom")
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Scope", selection: $selectedScope) {
                ForEach(UpcomingScope.allCases) { scope in
                    Text(scope.displayName).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            if selectedScope == .custom {
                HStack {
                    DatePicker(String(localized: "from", defaultValue: "From"), selection: $customStartDate, displayedComponents: .date)
                    DatePicker(String(localized: "to", defaultValue: "To"), selection: $customEndDate, in: customStartDate..., displayedComponents: .date)
                }
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .padding(.top, 8)
            }

            switch selectedScope {
            case .tomorrow:
                TaskListView(filter: .tomorrow)
            case .week:
                TaskListView(filter: .week)
            case .custom:
                TaskListView(filter: .custom, customStartDate: customStartDate, customEndDate: customEndDate)
            }
        }
        .navigationTitle(String(localized: "tabUpcoming", defaultValue: "Upcoming"))
    }
}
