//
//  OnboardingView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            // Welcome page
            OnboardingPageView(
                systemImage: "checklist",
                title: String(localized: "onboardingWelcomeTitle", defaultValue: "Welcome to ToDoList"),
                description: String(localized: "onboardingWelcomeDesc", defaultValue: "A simple, beautiful way to manage your tasks and stay organized."),
                buttonTitle: String(localized: "continue", defaultValue: "Continue")
            ) {
                withAnimation { currentPage = 1 }
            }
            .tag(0)

            // Notifications page
            OnboardingPageView(
                systemImage: "bell.badge",
                title: String(localized: "onboardingNotificationsTitle", defaultValue: "Stay on Track"),
                description: String(localized: "onboardingNotificationsDesc", defaultValue: "Enable notifications to get reminded about your tasks and never miss a deadline."),
                buttonTitle: String(localized: "enableNotifications", defaultValue: "Enable Notifications"),
                secondaryButtonTitle: String(localized: "skip", defaultValue: "Skip")
            ) {
                Task {
                    _ = try? await NotificationManager.shared.requestAuthorization()
                    await MainActor.run { withAnimation { currentPage = 2 } }
                }
            } secondaryAction: {
                withAnimation { currentPage = 2 }
            }
            .tag(1)

            // Completion page
            OnboardingPageView(
                systemImage: "checkmark.circle",
                title: String(localized: "onboardingCompleteTitle", defaultValue: "You're All Set!"),
                description: String(localized: "onboardingCompleteDesc", defaultValue: "Start adding tasks and take control of your day."),
                buttonTitle: String(localized: "getStarted", defaultValue: "Get Started")
            ) {
                appSettings.launchedBefore = true
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPageView: View {
    let systemImage: String
    let title: String
    let description: String
    let buttonTitle: String
    var secondaryButtonTitle: String?
    let action: () -> Void
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(buttonTitle) {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if let secondaryTitle = secondaryButtonTitle, let secondaryAction {
                    Button(secondaryTitle) {
                        secondaryAction()
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.bottom, 48)
        }
        .padding()
    }
}
