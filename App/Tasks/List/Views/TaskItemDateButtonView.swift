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
    
    var body: some View {
        if let taskDate = task.date {
            Button {
                
            } label: {
                Label(formatDate(taskDate), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondaryAccent)
                    .labelStyle(.titleAndIcon)
            }
        } else {
            EmptyView()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let isToday = calendar.isDateInToday(date)
        let isThisWeek = calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        
        let formatter = DateFormatter()
        
        if isToday {
            formatter.dateFormat = "HH:mm"
        } else if isThisWeek {
            formatter.dateFormat = "EEEE"
        } else {
            formatter.dateFormat = "d MMMM"
        }
        
        return formatter.string(from: date)
    }
}
