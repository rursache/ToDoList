//
//  TaskItemView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemView: View {
    @State var task: TaskModel
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                CheckButtonView(checked: $task.completed)
                    .padding(.top, 8)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                TaskItemTitleDetailView(task: task)
                
                if let _ = task.date {
                    HStack(spacing: 20) {
                        TaskItemDateButtonView(task: task)
                        
                        Spacer()
                        
                        TaskItemPriorityButtonView(task: task)
                            .padding(.trailing, 12)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    HStack {
                        TaskItemPriorityButtonView(task: task)
                        
                        Spacer()
                    }
                }
            }
        }.padding(.horizontal, -6)
    }
}

#Preview {
    NavigationStack {
        List(TaskModel.mocks) { task in
            NavigationLink {
                Text(task.name)
            } label: {
                TaskItemView(task: task)
            }
        }.navigationTitle("Tasks")
    }
}
