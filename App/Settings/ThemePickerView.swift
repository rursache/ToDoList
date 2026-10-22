//
//  ThemePickerView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        content
            .navigationTitle(String(localized: "theme", defaultValue: "Theme"))
            .toolbarVisibility(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private var content: some View {
        if #available(iOS 27, *), horizontalSizeClass == .regular {
            ScrollView {
                ColumnsLayout {
                    ForEach(Array(AppTheme.allCases.enumerated()), id: \.element) { position, theme in
                        themeButton(theme, insets: .columnCell)
                            .buttonStyle(ColumnCellButtonStyle())
                            .columnCell(position: position, count: AppTheme.allCases.count, separatorLeading: 68)
                    }
                }
                .columnsPanel()
                .padding(.bottom, 20)
            }
            .columnsScrollMargins()
            .contentMargins(.top, 6, for: .scrollContent)
            .background(Color(.systemGroupedBackground))
        } else {
            List(AppTheme.allCases) { theme in
                themeButton(theme)
            }
        }
    }

    private func themeButton(_ theme: AppTheme, insets: EdgeInsets = EdgeInsets()) -> some View {
        Button {
            applyTheme(theme)
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(theme.color)
                    .frame(width: 32, height: 32)

                Text(theme.displayName)
                    .foregroundStyle(Color.primary)

                Spacer()

                if theme == appSettings.theme {
                    Image(systemName: "checkmark")
                        .foregroundStyle(theme.color)
                        .fontWeight(.semibold)
                }
            }
            .padding(insets)
            .contentShape(.rect)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(theme.displayName)
        .accessibilityAddTraits(theme == appSettings.theme ? .isSelected : [])
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
