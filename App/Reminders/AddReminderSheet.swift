//
//  AddReminderSheet.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct AddReminderSheet: View {
    @Binding var date: Date
    @Binding var text: String
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "reminderNote", defaultValue: "Note (optional)"), text: $text)

                DatePicker(
                    String(localized: "reminderDate", defaultValue: "Date & Time"),
                    selection: $date,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            .navigationTitle(String(localized: "addReminder", defaultValue: "Add Reminder"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save", defaultValue: "Save")) {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddReminderSheet(
        date: .constant(Date()),
        text: .constant(""),
        onSave: {}
    )
}
