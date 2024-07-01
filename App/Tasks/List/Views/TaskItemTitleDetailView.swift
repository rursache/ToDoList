//
//  TaskItemTitleDetailView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemTitleDetailView: View {
    @State var task: TaskModel
    
    var body: some View {
        VStack(spacing: 6) {
            Text(task.name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let taskDetail = task.detail {
                HStack {
                    Text(taskDetail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
