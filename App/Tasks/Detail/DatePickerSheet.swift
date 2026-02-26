//
//  DatePickerSheet.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date?
    @Binding var hasTime: Bool

    @State private var selectedDate: Date = Date()
    @State private var selectedHasTime: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $selectedHasTime) {
                        Label(
                            String(localized: "addTime", defaultValue: "Time"),
                            systemImage: "clock"
                        )
                    }
                    .tint(.blue)
                    .onChange(of: selectedHasTime) { _, newValue in
                        if newValue {
                            let calendar = Calendar.current
                            let nextHour = calendar.date(bySettingHour: calendar.component(.hour, from: Date()) + 1, minute: 0, second: 0, of: selectedDate) ?? selectedDate
                            selectedDate = nextHour
                        } else {
                            selectedDate = selectedDate.startOfDay
                        }
                    }
                }

                Section {
                    DatePicker(
                        String(localized: "selectDate", defaultValue: "Select Date"),
                        selection: $selectedDate,
                        displayedComponents: selectedHasTime ? [.date, .hourAndMinute] : [.date]
                    )
                    .datePickerStyle(.graphical)
                    .listRowInsets(EdgeInsets(top: -12, leading: 12, bottom: 4, trailing: 12))
                    .animation(.spring(), value: selectedHasTime)
                }
            }
            .navigationTitle(String(localized: "pickDate", defaultValue: "Pick Date"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "done", defaultValue: "Done")) {
                        date = selectedDate
                        hasTime = selectedHasTime
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedDate = date ?? Date()
            selectedHasTime = hasTime
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    DatePickerSheet(date: .constant(Date()), hasTime: .constant(false))
}
