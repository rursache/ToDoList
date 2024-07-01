//
//  TaskItemPriorityButtonView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemPriorityButtonView: View {
    @State var task: TaskModel
    
    var body: some View {
        Button {
            
        } label: {
            Label(task.priority.name, systemImage: "flag.fill")
                .font(.caption)
                .foregroundStyle(task.priority.color)
                .labelStyle(.titleAndIcon)
        }
    }
}
