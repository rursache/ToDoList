//
//  App.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase

    private let modelContainer: ModelContainer
    private let appSettings = AppSettings.shared

    init() {
        self.modelContainer = DatabaseConfiguration.makeContainer()

        if AppSettings.demoMode {
            DatabaseConfiguration.seedDemoData(into: modelContainer.mainContext)
            appSettings.launchedBefore = true
        }
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
