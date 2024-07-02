//
//  TaskItemPriorityButtonView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemPriorityButtonView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var task: TaskModel
    @State private var showActionSheet: Bool = false
    
    var body: some View {
        Button {
            showActionSheet.toggle()
        } label: {
            Label(task.priority.name, systemImage: "flag.fill")
                .font(.caption)
                .foregroundStyle(task.priority.color)
                .labelStyle(.titleAndIcon)
        }.confirmationDialog("Select the task priority", isPresented: $showActionSheet, titleVisibility: .visible) {
            ForEach(TaskModel.TaskPriority.allCases) { priority in
                Button {
                    task.priority = priority
                    
                    dismiss()
                } label: {
                    Label(priority.name, systemImage: "flag.fill")
                        .labelStyle(.titleAndIcon)
                }.tint(priority.color)
            }
        }.buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        List(TaskModel.mocks) { task in
            NavigationLink {
                EmptyView()
            } label: {
                TaskItemView(task: task)
            }
        }.navigationTitle("Tasks")
    }
}
