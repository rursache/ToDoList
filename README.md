# RSToDoList

<p align="left">
  <img width="150" height="150" src="https://github.com/rursache/ToDoList/blob/master/Resources/icon.png" />
</p>

A simple To-do list app build for iOS 11+ in Swift 5

## Main features
- [x] Basic to do list features
	- [x] Persistent lists using Realm
	- [x] Add/delete items
	- [x] Edit task properties
	- [x] Complete items
	- [x] Date/Time for items
	- [x] Sort options
	- [x] Task filters
- [x] Theme support with custom App Icons
- [x] Multi-Language support
- [x] iCloud Kit support for syncing
- [x] Push notifications for reminders
	- [x] Synced push notifications between devices
- [ ] Optional lockdown with FaceID/TouchID or passcode
- [ ] Widget for Today tasks
- [ ] Tutorial/Onboarding
- [x] 3D Touch shortcuts

## Requirements
 - iOS 11.0+
 - Xcode 11.0+
 - Swift 5.0+

## How to run

1. Clone the repo
2. Run ```pod install``` in terminal to install required pods. Make sure you have [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) installed.
3. Turn on iCloud option in ```Capabilities``` and check ```CloudKit```. Turn on ```Background Modes``` and check ```Background fetch``` and ```Remote notification```.
4. (Optional) You might want to update or remove [Fabric](https://fabric.io/home) script located ```Build Phases```.

## Live demo

1. [AppStore]()
2. [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) - Use this [invitation link](http://l0ng.in/todolist).

## To do

- [ ] Add images as comments attachaments
- [ ] Tutorial/Onboarding
- [ ] Lockdown with FaceID/TouchID or passcode
- [ ] Smart dates (transform "'task name' today at 10:00" into a task with a date/time of today @ 10:00)
- [ ] Widget for Today tasks
- [ ] Rearrange tasks manually
 
### Improvements
- [ ] Reload notifications after user gave push permissions
- [ ] Themes view controller with previews

### Bugs
- [x] Changing a theme won't change settings nav controller until close/reopen screen
- [x] App will crash if no internet connection is available (fixed in [#955cc7d](https://github.com/rursache/ToDoList/commit/955cc7d895b92945d66aedec3fffb41be8da6c3f))
- [x] Comments and Reminders are not showing up while adding a task (fixed in [#955cc7d](https://github.com/rursache/ToDoList/commit/955cc7d895b92945d66aedec3fffb41be8da6c3f))

## Communication
- If you **found a bug**, open an [issue](https://github.com/rursache/ToDoList/issues).
- If you **have a feature request**, open an [issue](https://github.com/rursache/ToDoList/issues).
- If you **want to contribute**, submit a [pull request]().

## Acknowledgements & Frameworks used

An extensive list of acknowledgements for each external framework used for RSToDoList is also available in app by accessing the settings screen.

RSToDoList is currently using:

 - [LKAlertController](https://github.com/lightningkite/LKAlertController)
 - [ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0)
 - [IceCream (own fork)](https://github.com/rursache/IceCream)
 - [UnderKeyboard](https://github.com/evgenyneu/UnderKeyboard)
 - [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift)
 - [Realm & RealmSwift](https://realm.io/products/realm-database)
 - [RSTextViewMaster](https://github.com/rursache/RSTextViewMaster)
 - [BiometricAuthentication (own fork)](https://github.com/rursache/BiometricAuthentication)
 - [Loaf)](https://github.com/schmidyy/Loaf)
 - [Robin](https://github.com/ahmedabadie/Robin)
 - [Fabric & Crashlytics](https://fabric.io/home)

All icons used in RSToDoList are designed by Icons8.com and available [here](http://icons8.com).
Colors for themes and app icon are picked from [FlatUIColors.com](https://flatuicolors.com).

## License

RSToDoList is available under the GNU license. See the [LICENSE](https://github.com/rursache/ToDoList/blob/master/LICENSE) file for more info.
