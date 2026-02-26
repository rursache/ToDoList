//
//  ReminderRowView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct ReminderRowView: View {
    let reminder: ReminderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reminder.date.formatted(style: .reminder))
                .font(.body)
            if !reminder.text.isEmpty {
                Text(reminder.text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        ReminderRowView(reminder: {
            let r = ReminderModel()
            r.text = "Pick up groceries"
            r.date = Date().addingTimeInterval(3600)
            return r
        }())
    }
}
