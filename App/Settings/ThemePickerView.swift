//
//  ThemePickerView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        List(AppTheme.allCases) { theme in
            Button {
                applyTheme(theme)
            } label: {
                HStack(spacing: 16) {
                    Circle()
                        .fill(theme.color)
                        .frame(width: 32, height: 32)

                    Text(theme.displayName)
                        .foregroundStyle(.primary)

                    Spacer()

                    if theme == appSettings.theme {
                        Image(systemName: "checkmark")
                            .foregroundStyle(theme.color)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "theme", defaultValue: "Theme"))
        .toolbarVisibility(.hidden, for: .tabBar)
    }

    private func applyTheme(_ theme: AppTheme) {
        appSettings.selectedTheme = theme.rawValue
        UIApplication.shared.setAlternateIconName(theme.alternateIconName)
    }
}

#Preview {
    NavigationStack {
        ThemePickerView()
    }
    .environment(AppSettings.shared)
}
