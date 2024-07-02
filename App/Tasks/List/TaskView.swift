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
    @State private var viewModel = TaskViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                RSQueryView(for: TaskModel.self) { tasks in
                    let sortedTasks = tasks.sorted()
                    
                    Group {
                        if !sortedTasks.isEmpty {
                            ForEach(sortedTasks) { task in
                                NavigationLink {
                                    Text(task.name)
                                } label: {
                                    TaskItemView(task: task)
                                }
                            }.onDelete { indexSet in
                                viewModel.deleteItemModels(sortedTasks, at: indexSet, modelContext: modelContext)
                            }
                        } else {
                            TaskItemEmptyStateView(searchText: $searchText) {
                                viewModel.addItemModel(modelContext: modelContext)
                            }
                        }
                    }.onChange(of: sortedTasks, initial: true, { _, newValue in
                        print("Number of tasks: \(newValue.count)")
                    }).animation(.bouncy, value: sortedTasks.count)
                } filter: {
                    #Predicate {
                        !searchText.isEmpty ? $0.name.localizedStandardContains(searchText) : true
                    }
                }
            }
            .navigationTitle("To-do list")
            .searchable(text: $searchText, prompt: "Search...")
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }.safeAreaPadding(.bottom, 70)
        }.overlay {
            RoundPlusButtonView {
                viewModel.addItemModel(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    TaskView()
        .modelContainer(DatabaseManager.simulatorModelContainer)
}


