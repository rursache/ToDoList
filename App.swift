//
//  App.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let modelContainer: ModelContainer
    private let appSettings = AppSettings.shared

    init() {
        self.modelContainer = DatabaseConfiguration.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appSettings.launchedBefore {
                    AdaptiveNavigationView()
                } else {
                    OnboardingView()
                }
            }
            .tint(appSettings.theme.color)
            .environment(appSettings)
        }
        .modelContainer(modelContainer)
    }
}
