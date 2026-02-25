//
//  SettingsView.swift
//  ToDoList
//
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var showingFeedback = false
    @State private var showingAbout = false

    var body: some View {
        @Bindable var settings = appSettings

        Form {
            Section(String(localized: "settingsPreferences", defaultValue: "Preferences")) {
                Picker(selection: $settings.startPage) {
                    Text(String(localized: "filterToday", defaultValue: "Today")).tag(0)
                    Text(String(localized: "filterAll", defaultValue: "All Tasks")).tag(1)
                    Text(String(localized: "filterTomorrow", defaultValue: "Tomorrow")).tag(2)
                    Text(String(localized: "filterWeek", defaultValue: "Next 7 Days")).tag(3)
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

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(String(localized: "language", defaultValue: "Language"), systemImage: "globe")
                }
                .tint(.primary)

                Toggle(isOn: $settings.openLinksInApp) {
                    Label(String(localized: "openLinksInApp", defaultValue: "Open Links In App"), systemImage: "safari")
                }
            }

            Section(String(localized: "settingsToggles", defaultValue: "Features")) {
                Toggle(isOn: Binding(
                    get: { !appSettings.disableAutoReminders },
                    set: { appSettings.disableAutoReminders = !$0 }
                )) {
                    Label(String(localized: "autoReminders", defaultValue: "Automatic Reminders"), systemImage: "bell.badge")
                }

                Toggle(isOn: $settings.helpPrompts) {
                    Label(String(localized: "helpPrompts", defaultValue: "Helpful Prompts"), systemImage: "questionmark.circle")
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
        .alert(String(localized: "about", defaultValue: "About"), isPresented: $showingAbout) {
            Button(String(localized: "ok", defaultValue: "OK")) {}
        } message: {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            Text("ToDoList v\(version) (\(build))\n\nMade with love by RanduSoft")
        }
    }
}

struct FeedbackMailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["contact@randusoft.ro"])
        vc.setSubject("ToDoList Feedback")

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let device = UIDevice.current.model
        let ios = UIDevice.current.systemVersion
        vc.setMessageBody("\n\n---\nApp: ToDoList v\(version)\nDevice: \(device)\niOS: \(ios)", isHTML: false)

        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    class Coordinator: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        @MainActor func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}
