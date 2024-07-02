//
//  TaskItemDateButtonView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemDateButtonView: View {
    @State var task: TaskModel
    @State private var datePickerVisible: Bool = false
    
    var body: some View {
        Button {
            datePickerVisible.toggle()
        } label: {
            Label(formatDate(task.date, time: task.time), systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondaryAccent)
                .labelStyle(.titleAndIcon)
        }.if(UIDevice.current.userInterfaceIdiom == .phone, transform: { button in
            button.sheet(isPresented: $datePickerVisible, content: {
                TaskItemDatePickerView(date: task.date, time: task.time, pickerUpdated: { date, time in
                    task.date = date
                    task.time = time
                }).presentationDragIndicator(.visible).presentationDetents([.height(TaskItemDatePickerView.height)])
            })
        }).if(UIDevice.current.userInterfaceIdiom == .pad, transform: { button in
            button.popover(isPresented: $datePickerVisible) {
                TaskItemDatePickerView(date: task.date, time: task.time, pickerUpdated: { date, time in
                    task.date = date
                    task.time = time
                })
            }
        }).buttonStyle(.plain)
    }
    
    private func formatDate(_ date: Date?, time: Date?) -> String {
        guard let date else {
            fatalError("Date is missing")
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let isToday = calendar.isDateInToday(date)
        let isThisWeek = calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        
        let dateFormatter = DateFormatter()
        
        if isToday {
            dateFormatter.dateFormat = "Today"
        } else if isThisWeek {
            dateFormatter.dateFormat = "EEEE"
        } else {
            dateFormatter.dateFormat = "d MMM"
        }
        
        var result = dateFormatter.string(from: date)
        
        if let time {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            result += " @ " + timeFormatter.string(from: time)
        }
        
        return result
    }
}
