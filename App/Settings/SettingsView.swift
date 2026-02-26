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
    @State private var showingOnboarding = false
    @State private var safariURL: URL?

    var body: some View {
        @Bindable var settings = appSettings

        Form {
            Section {
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
                            .accessibilityHidden(true)
                    }
                }

                Toggle(isOn: $settings.openLinksInApp) {
                    Label(String(localized: "openLinksInApp", defaultValue: "Open Links In App"), systemImage: "safari")
                }
            }

            Section {
                Picker(selection: $settings.autoReminderMinutes) {
                    ForEach(AutoReminderInterval.allCases) { interval in
                        Text(interval.displayName).tag(interval.rawValue)
                    }
                } label: {
                    Label(String(localized: "autoReminders", defaultValue: "Automatic\nReminders"), systemImage: "bell.badge")
                }
            }

            Section {
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
                    safariURL = URL(string: "https://randusoft.ro/tos.html")
                } label: {
                    Label(String(localized: "termsOfService", defaultValue: "Terms of Service"), systemImage: "doc.text")
                }
                .tint(.primary)

                Button {
                    safariURL = URL(string: "https://randusoft.ro/pp.html")
                } label: {
                    Label(String(localized: "privacyPolicy", defaultValue: "Privacy Policy"), systemImage: "lock.shield")
                }
                .tint(.primary)

                Button {
                    safariURL = URL(string: "https://github.com/rursache/ToDoList")
                } label: {
                    Label(String(localized: "sourceCode", defaultValue: "Source Code"), systemImage: "curlybraces")
                }
                .tint(.primary)
            } footer: {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                Text(verbatim: "\(AppSettings.appName) v\(version) (\(build))")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
        }
        .navigationTitle(String(localized: "tabSettings", defaultValue: "Settings"))
        .toolbarTitleDisplayMode(.inlineLarge)
        .sheet(isPresented: $showingFeedback) {
            FeedbackMailView()
        }
        .sheet(item: $safariURL) { url in
            SFSafariView(url: url)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
                .environment(appSettings)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppSettings.shared)
}
