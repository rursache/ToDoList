//
//  TaskItemEmptyStateView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemEmptyStateView: View {
    @Binding var searchText: String
    var action: () -> Void
    
    var body: some View {
        if !searchText.isEmpty {
            ContentUnavailableView(label: {
                Label("No Tasks", systemImage: "text.badge.checkmark")
            }, description: {
                Text("Try using other keywords")
            })
        } else {
            ContentUnavailableView(label: {
                Label("No Tasks", systemImage: "text.badge.checkmark")
            }, description: {
                Text("Your tasks will appear here")
            }, actions: {
                Button {
                    action()
                } label: {
                    Text("Add Task")
                }
            })
        }
    }
}

#Preview {
    TaskItemEmptyStateView(searchText: .constant(""), action: {})
}
