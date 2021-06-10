# RSToDoList

<p align="left">
  <img width="150" height="150" src="https://github.com/rursache/ToDoList/blob/master/WatchApp/Assets.xcassets/watchlogo.imageset/watchlogo.png" />
</p>

A simple To-do list app build for iPhone, iPad and Apple Watch in Swift 5 (iOS 11+, watchOS 6+)

## Main features
- [x] Persistent task lists using Realm
- [x] iCloud Kit support for syncing
- [x] Push notifications for reminders (Synced between devices)
- [x] Add/delete/edit/complete tasks
- [x] Set task Date & Time + custom reminders and comments (images too)
- [x] Sort/Filter/Prioritise tasks
- [x] iPad app
- [x] Watch app
- [x] Widget for Today tasks
- [x] Theme support with custom App Icons
- [x] Multi-Language support
- [x] 3D Touch shortcuts
- [x] Dark mode
- [x] Onboarding/tutorial

## Requirements
 - iOS 11.0+
 - Xcode 11.0+
 - Swift 5.0+

## How to run

1. Clone the repo
2. Turn on iCloud option in ```Signing & Capabilities``` and check ```CloudKit```. Turn on ```Background Modes``` and check ```Background fetch``` + ```Remote notification```.
3. Make sure to update your app group config (```Signing & Capabilities```, ```App Groups```) and id string in ```RealmManager.swift```.

## Live demo

[ToDoList - Task Manager by RanduSoft - AppStore](https://apps.apple.com/us/app/todolist-task-manager/id1454122524?ls=1)

## Roadmap

### Features

- [ ] Lockdown with FaceID/TouchID or passcode (using [BiometricAuthentication](https://github.com/rursache/BiometricAuthentication))
- [ ] Smart dates (transform "'task name' today at 10:00" into a task with a date/time of today @ 10:00)
- [ ] Rearrange tasks manually
- [ ] Catalyst support for macOS
 
### Improvements/To Do
- [ ] iOS 14 Widget
- [ ] watchOS complications + sync improvements
- [ ] Reload notifications after user gave push permissions if initially declined 

## Communication
- If you **found a bug**, open an [issue](https://github.com/rursache/ToDoList/issues).
- If you **have a feature request**, open an [issue](https://github.com/rursache/ToDoList/issues).
- If you **want to contribute**, submit a [pull request]().

## Acknowledgements & Frameworks used

An extensive list of acknowledgements for each external framework used for RSToDoList is also available in app by accessing the settings screen.

RSToDoList is currently using:

 - [LKAlertController](https://github.com/lightningkite/LKAlertController)
 - [ActionSheetPicker-3.0](https://github.com/rursache/ActionSheetPicker-3.0)
 - [IceCream](https://github.com/rursache/IceCream)
 - [UnderKeyboard](https://github.com/rursache/UnderKeyboard)
 - [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift)
 - [Realm & RealmSwift](https://realm.io/products/realm-database)
 - [RSTextViewMaster](https://github.com/rursache/RSTextViewMaster)
 - [Loaf](https://github.com/schmidyy/Loaf)
 - [Robin](https://github.com/ahmedabadie/Robin)
 - [BulletinBoard](https://github.com/alexaubry/BulletinBoard)

All icons used in RSToDoList are designed by Icons8.com and available [here](http://icons8.com).
Colors for themes and app icon are picked from [FlatUIColors.com](https://flatuicolors.com).

## License

RSToDoList is available under the GNU license. See the [LICENSE](https://github.com/rursache/ToDoList/blob/master/LICENSE) file for more info.
