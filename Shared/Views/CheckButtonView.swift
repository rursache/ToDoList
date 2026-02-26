//
//  CheckButtonView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct CheckButtonView: View {
    @Environment(AppSettings.self) private var appSettings
    @Binding var checked: Bool

    var body: some View {
        VStack {
            Button {
                withAnimation(.spring) {
                    checked.toggle()
                }
            } label: {
                Image(systemName: checked ? "checkmark.circle" : "circle")
                    .font(.title)
            }
            .buttonStyle(.plain)
            .foregroundStyle(appSettings.theme.color)
            .aspectRatio(1, contentMode: .fit)
            .sensoryFeedback(.success, trigger: checked)
            .accessibilityLabel(checked ? "Completed" : "Not completed")
            .accessibilityHint("Double tap to toggle")
        }.frame(maxWidth: 34)
    }
}

#Preview {
    VStack {
        CheckButtonView(checked: .constant(true))
        CheckButtonView(checked: .constant(false))
    }
    .environment(AppSettings.shared)
}
