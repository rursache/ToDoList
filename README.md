# ToDoList

<p align="left">
  <img width="150" height="150" src="Resources/Icon.jpg" />
</p>

A modern, open-source To-Do list app built entirely in SwiftUI for iPhone and iPad. Featuring SwiftData with iCloud sync, iOS 26 Liquid Glass design, and Swift 6 strict concurrency.

> [!NOTE]
> This is a complete rewrite of the [original ToDoList](https://github.com/rursache/ToDoList/tree/v1.5.2) — from UIKit/Storyboards/Realm to a modern SwiftUI stack with zero third-party dependencies.

## Features

- [x] **SwiftData** persistence with **CloudKit** sync across devices
- [x] **iOS 26 Liquid Glass** design language throughout
- [x] Add, edit, complete, and delete tasks
- [x] Set due date & time with graphical date picker
- [x] Task priorities (Highest, High, Normal, Low)
- [x] Comments on tasks (text and images via PhotosPicker)
- [x] Reminders with local push notifications
- [x] Automatic reminders (30 min before due date)
- [x] Sort tasks by date or priority
- [x] Search across all task lists
- [x] Filter views: Today, All, Upcoming (Tomorrow / Week / Custom interval), Completed
- [x] iPad support with `NavigationSplitView` sidebar
- [x] 7 color themes with alternate app icons
- [x] 3-page onboarding with notification permission flow
- [x] Settings: start page, theme, language, auto-reminders, feedback email
- [x] Soft-delete pattern for CloudKit compatibility
- [x] Context menus on task rows (Edit, Complete, Delete)
- [x] Zero third-party dependencies

## Requirements

- iOS 26.0+
- Xcode 26+
- Swift 6.0

## How to run

1. Clone the repo
2. Open `ToDoList.xcodeproj` in Xcode
3. In **Signing & Capabilities**:
   - Set your development team
   - Enable **iCloud** with **CloudKit** (container: `iCloud.ro.randusoft.todolist`)
   - Enable **App Groups** (`group.ro.randusoft.todolist`)
   - Enable **Push Notifications**
4. Build and run on a simulator or device

## Architecture

```
App.swift                          # App entry point, ModelContainer, theming
AppDelegate.swift                  # UNUserNotificationCenter delegate

App/
├── Navigation/                    # AdaptiveNavigationView, TabView, Sidebar
├── Tasks/
│   ├── List/                      # TaskListView, TaskRowView, UpcomingTasksView
│   └── Detail/                    # TaskEditView (create/edit sheet)
├── Comments/                      # CommentsView, CommentRowView
├── Reminders/                     # RemindersView, AddReminderSheet
├── Settings/                      # SettingsView, ThemePickerView
└── Onboarding/                    # OnboardingView

Models/                            # SwiftData models (Task, Comment, Reminder)
Database/                          # DatabaseConfiguration (ModelContainer factory)
Services/                          # AppSettings, NotificationManager
Shared/                            # CheckButtonView, Date+Extensions
Helpers/                           # Binding extensions
```

## Roadmap

- [ ] WidgetKit widget for Today tasks
- [ ] Localization (English, Romanian, Traditional Chinese — ported from v1)
- [ ] Smart date parsing ("Buy groceries tomorrow at 10am")
- [ ] Biometric lock (Face ID / Touch ID)
- [ ] Manual task reordering
- [ ] Accessibility audit

## Communication

- If you **found a bug**, open an [issue](https://github.com/rursache/ToDoList/issues).
- If you **have a feature request**, open an [issue](https://github.com/rursache/ToDoList/issues).
- If you **want to contribute**, submit a [pull request](https://github.com/rursache/ToDoList/pulls).

## License

ToDoList is available under the GNU license. See the [LICENSE](https://github.com/rursache/ToDoList/blob/master/LICENSE) file for more info.
