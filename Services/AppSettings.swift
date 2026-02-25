//
//  AppSettings.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

@MainActor @Observable
final class AppSettings: Sendable {
    static let shared = AppSettings()

    var selectedTheme: Int {
        get { access(keyPath: \.selectedTheme); return UserDefaults.standard.integer(forKey: "selectedTheme") }
        set { withMutation(keyPath: \.selectedTheme) { UserDefaults.standard.set(newValue, forKey: "selectedTheme") } }
    }

    var startPage: Int {
        get { access(keyPath: \.startPage); return UserDefaults.standard.integer(forKey: "startPage") }
        set { withMutation(keyPath: \.startPage) { UserDefaults.standard.set(newValue, forKey: "startPage") } }
    }

    var disableAutoReminders: Bool {
        get { access(keyPath: \.disableAutoReminders); return UserDefaults.standard.bool(forKey: "disableAutoReminders") }
        set { withMutation(keyPath: \.disableAutoReminders) { UserDefaults.standard.set(newValue, forKey: "disableAutoReminders") } }
    }

    var helpPrompts: Bool {
        get { access(keyPath: \.helpPrompts); return UserDefaults.standard.bool(forKey: "helpPrompts") }
        set { withMutation(keyPath: \.helpPrompts) { UserDefaults.standard.set(newValue, forKey: "helpPrompts") } }
    }

    var openLinksInApp: Bool {
        get { access(keyPath: \.openLinksInApp); return UserDefaults.standard.bool(forKey: "openLinksInApp") }
        set { withMutation(keyPath: \.openLinksInApp) { UserDefaults.standard.set(newValue, forKey: "openLinksInApp") } }
    }

    var launchedBefore: Bool {
        get { access(keyPath: \.launchedBefore); return UserDefaults.standard.bool(forKey: "launchedBefore") }
        set { withMutation(keyPath: \.launchedBefore) { UserDefaults.standard.set(newValue, forKey: "launchedBefore") } }
    }

    var theme: AppTheme {
        AppTheme(rawValue: selectedTheme) ?? .red
    }

    private init() {}
}

enum AppTheme: Int, CaseIterable, Identifiable {
    case red = 0
    case blue
    case green
    case yellow
    case orange
    case pink
    case black

    var id: Int { rawValue }

    var color: Color {
        switch self {
        case .red: Color(red: 214/255, green: 48/255, blue: 49/255)
        case .blue: Color(red: 9/255, green: 132/255, blue: 227/255)
        case .green: Color(red: 32/255, green: 191/255, blue: 107/255)
        case .yellow: Color(red: 241/255, green: 196/255, blue: 15/255)
        case .orange: Color(red: 243/255, green: 156/255, blue: 18/255)
        case .pink: Color(red: 224/255, green: 83/255, blue: 132/255)
        case .black: Color(red: 45/255, green: 52/255, blue: 54/255)
        }
    }

    var displayName: String {
        switch self {
        case .red: "Alizarin Red"
        case .blue: "Vanadyl Blue"
        case .green: "Skirret Green"
        case .yellow: "Sunflower Yellow"
        case .orange: "Radiant Orange"
        case .pink: "Rose Pink"
        case .black: "Midnight Black"
        }
    }

    var alternateIconName: String? {
        switch self {
        case .red: nil
        case .blue: "IconBlue"
        case .green: "IconGreen"
        case .yellow: "IconYellow"
        case .orange: "IconOrange"
        case .pink: "IconPinkAlt"
        case .black: "IconBlack"
        }
    }
}
