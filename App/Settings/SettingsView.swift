//
//  SettingsView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import MessageUI // Required for MFMailComposeViewController.canSendMail()

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var showingFeedback = false
    @State private var showingAbout = false
    @State private var showingOnboarding = false

    var body: some View {
        @Bindable var settings = appSettings

        Form {
            Section(String(localized: "settingsPreferences", defaultValue: "Preferences")) {
                Picker(selection: $settings.startPage) {
                    Text(String(localized: "filterInbox", defaultValue: "Inbox")).tag(0)
                    Text(String(localized: "filterToday", defaultValue: "Today")).tag(1)
                    Text(String(localized: "filterUpcoming", defaultValue: "Upcoming")).tag(2)
                } label: {
                    Label(String(localized: "startPage", defaultValue: "Start Page"), systemImage: "star")
                }

                NavigationLink {
                    ThemePickerView()
                } label: {
                    HStack {
                        Label(String(localized: "theme", defaultValue: "Theme"), systemImage: "paintpalette")
                        Spacer()
                        Circle()
                            .fill(appSettings.theme.color)
                            .frame(width: 20, height: 20)
                    }
                }

                Toggle(isOn: $settings.openLinksInApp) {
                    Label(String(localized: "openLinksInApp", defaultValue: "Open Links In App"), systemImage: "safari")
                }
            }

            Section(String(localized: "settingsToggles", defaultValue: "Features")) {
                Picker(selection: $settings.autoReminderMinutes) {
                    ForEach(AutoReminderInterval.allCases) { interval in
                        Text(interval.displayName).tag(interval.rawValue)
                    }
                } label: {
                    Label(String(localized: "autoReminders", defaultValue: "Automatic\nReminders"), systemImage: "bell.badge")
                }

            }

            Section(String(localized: "settingsActions", defaultValue: "Other")) {
                if MFMailComposeViewController.canSendMail() {
                    Button {
                        showingFeedback = true
                    } label: {
                        Label(String(localized: "feedback", defaultValue: "Send Feedback"), systemImage: "envelope")
                    }
                    .tint(.primary)
                }

                Button {
                    showingOnboarding = true
                } label: {
                    Label(String(localized: "onboarding", defaultValue: "Onboarding"), systemImage: "hand.wave")
                }
                .tint(.primary)

                Button {
                    showingAbout = true
                } label: {
                    Label(String(localized: "about", defaultValue: "About"), systemImage: "info.circle")
                }
                .tint(.primary)
            }
        }
        .navigationTitle(String(localized: "tabSettings", defaultValue: "Settings"))
        .toolbarTitleDisplayMode(.inlineLarge)
        .sheet(isPresented: $showingFeedback) {
            FeedbackMailView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
                .environment(appSettings)
        }
        .alert(String(localized: "about", defaultValue: "About"), isPresented: $showingAbout) {
            Button(String(localized: "ok", defaultValue: "OK")) {}
        } message: {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            Text("ToDoList v\(version) (\(build))\n\nMade with love by RanduSoft")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppSettings.shared)
}
