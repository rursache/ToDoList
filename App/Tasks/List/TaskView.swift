//
//  HomeView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskModel]
    @State private var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationSplitView {
            List {
                if !tasks.isEmpty {
                    Section {
                        ForEach(tasks) { task in
                            NavigationLink {
                                Text(task.name)
                            } label: {
                                TaskItemView(task: task)
                            }
                        }.onDelete { indexSet in
                            viewModel.deleteItemModels(tasks, at: indexSet, modelContext: modelContext)
                        }
                    }
                } else {
                    ContentUnavailableView("No Tasks", systemImage: "text.badge.checkmark")
                }
            }.safeAreaPadding(.bottom, 80)
            .navigationTitle("To-do list")
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
//                ToolbarItem {
//                    Button {
//                        viewModel.addItemModel(modelContext: modelContext)
//                    } label: {
//                        Label("Add ItemModel", systemImage: "plus")
//                    }
//                }
            }.overlay {
                ZStack {
                    Button {
                        viewModel.addItemModel(modelContext: modelContext)
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(.accent)
                            .clipShape(.circle)
                    }.padding()
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }.animation(.bouncy, value: tasks.count)
        } detail: {
            Text("Select a task")
        }.onChange(of: tasks, initial: true, { _, newValue in
            print("Number of tasks: \(newValue.count)")
        })
    }
}

#Preview {
    TaskView()
        .modelContainer(DatabaseManager.simulatorModelContainer)
}
