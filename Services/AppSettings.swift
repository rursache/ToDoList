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

    static let appName = "ToDoList"

    var selectedTheme: Int {
        get { access(keyPath: \.selectedTheme); return UserDefaults.standard.integer(forKey: "selectedTheme") }
        set { withMutation(keyPath: \.selectedTheme) { UserDefaults.standard.set(newValue, forKey: "selectedTheme") } }
    }

    var startPage: Int {
        get { access(keyPath: \.startPage); return UserDefaults.standard.integer(forKey: "startPage") }
        set { withMutation(keyPath: \.startPage) { UserDefaults.standard.set(newValue, forKey: "startPage") } }
    }

    var autoReminderMinutes: Int {
        get { access(keyPath: \.autoReminderMinutes); return UserDefaults.standard.integer(forKey: "autoReminderMinutes") }
        set { withMutation(keyPath: \.autoReminderMinutes) { UserDefaults.standard.set(newValue, forKey: "autoReminderMinutes") } }
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

    private init() {
        UserDefaults.standard.register(defaults: ["startPage": 1, "autoReminderMinutes": 10])
    }
}
