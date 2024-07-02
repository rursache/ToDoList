//
//  TaskItemDatePickerView.swift
//  ToDoList
//
//  Created by Radu Ursache on 02.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct TaskItemDatePickerView: View {
    @State var date: Date?
    @State var time: Date?
    
    var pickerUpdated: (_ date: Date?, _ time: Date?) -> Void
    
    var body: some View {
        VStack {
            DatePicker("", selection: $date ?? Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.top)
            
            HStack {
                Text("Time")
                
                DatePicker("", selection: $time ?? Date(), displayedComponents: .hourAndMinute)
            }
            
            Divider()
            
            HStack {
                Button {
                    date = nil
                } label: {
                    Text("Remove Date")
                }.buttonStyle(.borderedProminent)
                    .tint(.accent)
                
                Spacer()
                
                Button {
                    time = nil
                } label: {
                    Text("Remove Time")
                }.buttonStyle(.borderedProminent)
                    .tint(.secondaryAccent)
            }.padding(.vertical)
        }.onChange(of: date, initial: false, { _, newValue in
            pickerUpdated(newValue, time)
        }).onChange(of: time, initial: false, { _, newValue in
            pickerUpdated(date, newValue)
        }).frame(minHeight: TaskItemDatePickerView.height).padding(16)
    }
}

extension TaskItemDatePickerView {
    static let height: CGFloat = 460
}

#Preview {
    NavigationStack {
        List {
            ForEach(1...20, id: \.hashValue) { index in
                Text("Preview \(index)")
            }
        }.navigationTitle("Preview")
    }.if(UIDevice.current.userInterfaceIdiom == .phone, transform: { button in
        button.sheet(isPresented: .constant(true)) {
            TaskItemDatePickerView(date: nil, time: nil, pickerUpdated: { _, _ in })
                .presentationDragIndicator(.visible).presentationDetents([.height(TaskItemDatePickerView.height)])
        }
    }).if(UIDevice.current.userInterfaceIdiom == .pad, transform: { button in
        button.popover(isPresented: .constant(true)) {
            TaskItemDatePickerView(date: nil, time: nil, pickerUpdated: { _, _ in })
        }
    })
}
