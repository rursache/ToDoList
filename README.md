# ToDoList

<p align="left">
  <img width="150" height="150" src="https://i.imgur.com/gfXtj2j.png" />
</p>

A modern, open-source To-Do list app built entirely in SwiftUI for iPhone and iPad. Featuring SwiftData with iCloud sync, iOS 26 Liquid Glass design, and Swift 6 strict concurrency.

> [!NOTE]
> This is a complete rewrite of the [original ToDoList](https://github.com/rursache/ToDoList/tree/v1.5.2) — from UIKit/Storyboards/Realm to a modern SwiftUI stack with zero third-party dependencies.

## Features

- [x] **SwiftData** persistence with **CloudKit** sync across devices
- [x] **iOS 26 Liquid Glass** design language throughout
- [x] Add, edit, complete, and delete tasks
- [x] Task descriptions
- [x] Set due date & time with graphical date picker
- [x] Date-only tasks (no specific time) or date + time
- [x] Task priorities (Highest, High, Normal, Low)
- [x] Comments on tasks (text and images via PhotosPicker)
- [x] Reminders with local push notifications
- [x] Configurable automatic reminders (None / 10min / 30min / 1h before due)
- [x] Sort tasks by date or priority
- [x] Search across all task lists
- [x] Filter views: Inbox, Today, Upcoming, Completed
- [x] Upcoming tasks grouped by day sections
- [x] iPad support with `NavigationSplitView` sidebar
- [x] 7 color themes
- [x] 3-page onboarding with notification permission flow
- [x] Localization support (English, Romanian)
- [x] Settings: start page, theme, auto-reminders, feedback email
- [x] Soft-delete pattern for CloudKit compatibility
- [x] Context menus on task rows (Edit, Complete, Delete)
- [x] Widgets (Today and Upcoming in all size classes)
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

## Roadmap

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
