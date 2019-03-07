# RSToDoList

<p align="left">
  <img width="150" height="150" src="https://github.com/iPhoNewsRO/ToDoList/blob/master/Resources/icon.png" />
</p>

A simple To-do list app build for iOS 11+ in Swift 4.2 

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
- [ ] Tutorial/Onboarding
- [x] iCloud Kit support for syncing
- [x] Push notifications for reminders
	- [x] Synced push notifications between devices
- [ ] Optional lockdown with FaceID/TouchID or passcode
- [ ] Widget for Today tasks
- [x] 3D Touch shortcuts

## Requirements
 - iOS 11.0+
 - Xcode 9.0+
 - Swift 4.2+

## How to run

1. Clone the repo
2. Run ```pod install``` in terminal to install required pods. Make sure you have [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) installed.
3. Turn on iCloud option in ```Capabilities``` and check ```CloudKit```. Turn on ```Background Modes``` and check ```Background fetch``` and ```Remote notification```.
4. (Optional) You might want to update or remove [Fabric](https://fabric.io/home) script located ```Build Phases```.

## Live demo

1. [AppStore]()
2. [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) - Use this [invitation link](http://l0ng.in/todolist).

## To do

- [ ] Search bar in home and tasks view
- [ ] Reminders viewer/editor (delete/edit current notifications)
- [ ] Tutorial/Onboarding
- [ ] Multi-Language support
- [ ] Lockdown with FaceID/TouchID or passcode
- [ ] Rearrange tasks manually
- [ ] Smart dates (transform "'task name' today at 10:00" into a task with a date/time of today 10:00)
- [ ] Widget for Today tasks
 
### Improvements
- [ ] Reload notifications after user gave push permissions
- [ ] Themes view controller with previews
- [ ] Better hashtag integration in comments
- [ ] Integrate Fabric & Crashlytics for a better understanding of crashes

### Bugs
- [x] App will crash if no internet connection is available (fixed in [#955cc7d](https://github.com/iPhoNewsRO/ToDoList/commit/955cc7d895b92945d66aedec3fffb41be8da6c3f))
- [ ] Comments are not showing up while adding a task

## Communication
- If you **found a bug**, open an [issue](https://github.com/iPhoNewsRO/ToDoList/issues).
- If you **have a feature request**, open an [issue](https://github.com/iPhoNewsRO/ToDoList/issues).
- If you **want to contribute**, submit a [pull request]().

## Acknowledgements & Frameworks used

An extensive list of acknowledgements for each external framework used for RSToDoList is also available in app by accessing the settings screen.

RSToDoList is currently using:

 - [LKAlertController](https://github.com/lightningkite/LKAlertController)
 - [ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0)
 - [IceCream (own fork)](https://github.com/iPhoNewsRO/IceCream)
 - [UnderKeyboard](https://github.com/evgenyneu/UnderKeyboard)
 - [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift)
 - [Realm & RealmSwift](https://realm.io/products/realm-database)
 - [RSTextViewMaster](https://github.com/iPhoNewsRO/RSTextViewMaster)
 - [BiometricAuthentication (own fork)](https://github.com/iPhoNewsRO/BiometricAuthentication)
 - [ImpressiveNotifications (own fork)](https://github.com/iPhoNewsRO/ImpressiveNotifications)
 - [Robin](https://github.com/ahmedabadie/Robin)
 - [Fabric & Crashlytics](https://fabric.io/home)

All icons used in RSToDoList are designed by Icons8.com and available [here](http://icons8.com).
Colors for themes and app icon are picked from [FlatUIColors.com](https://flatuicolors.com).

## License

RSToDoList is available under the GNU license. See the [LICENSE](https://github.com/iPhoNewsRO/ToDoList/blob/master/LICENSE) file for more info.
