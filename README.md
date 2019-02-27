# RSToDoList

<p align="center">
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
- [x] Theme support with custom App Icons
- [ ] Tutorial/Onboarding
- [x] iCloud Kit support for syncing
- [ ] Push notifications for reminders
	- [ ] Synced push notifications between devices
- [ ] Optional lockdown with FaceID/TouchID or passcode
- [ ] Widget for Today tasks

## How to run

1. Clone the repo
2. Run ```pod install``` in terminal to install required pods. Make sure you have (CocoaPods)[https://guides.cocoapods.org/using/getting-started.html] installed.
3. Turn on iCloud option in ```Capabilities``` and check ```CloudKit```. Turn on ```Background Modes``` and check ```Background fetch``` and ```Remote notification```.

## Live demo

Download [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) on your device and use [this](http://l0ng.in/todolist) link to get the latest build.

# To do

### v1.0
- [x] Home page
	- [x] Tableview with All, Today, Tomorrow, Next 7 Days
	- [ ] Search bar
- [x] Tasks view page
	- [x] Custom cell
	- [x] Add item UI/page
	- [x] Sort
	- [x] Delete
	- [x] Edit task
	- [ ] Search bar
- [x] Add task view
	- [x] Date picker
	- [x] Priority selector
	- [x] Comment viewer/editor (delete/edit current comments)
	- [x] Animations
- [x] Settings page
	- [x] Select start page
	- [x] Manual iCloud Sync
	- [x] Themes 
	- [x] Feedback via email
	- [x] Option to open links in app or in safari
- [x] Basic features
- [x] iCloud sync
- [ ] Push notifications

### v1.0.1
- [ ] Custom intervals page for tasks
- [ ] Tutorial/Onboarding
- [x] Theming 
- [ ] Multi-Language support
- [x] Custom app icons
- [ ] Sync push notifications between devices
- [ ] Lockdown with FaceID/TouchID or passcode
- [ ] Rearrange tasks manually
- [ ] Smart dates (transform "'task name' today at 10:00" into a task with a date/time of today 10:00)
- [ ] Widget for Today tasks
 
### Improvements
- [ ] Themes view controller with previews
- [ ] Better hashtag integration in comments

### Known bugs
- [x] IceCream won't sync task comments to cloudkit (https://github.com/caiyue1993/IceCream/issues/119)

## Acknowledgements & Frameworks used

An extensive list of acknowledgements for each external framework used is also available in app by accessing the settings screen.

ToDoList is currently using:

 - [LKAlertController](https://github.com/lightningkite/LKAlertController)
 - [ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0)
 - [IceCream (own fork)](https://github.com/iPhoNewsRO/IceCream)
 - [UnderKeyboard](https://github.com/evgenyneu/UnderKeyboard)
 - [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift)
 - [Realm & RealmSwift](https://realm.io/products/realm-database)
 - [RSTextViewMaster](https://github.com/iPhoNewsRO/RSTextViewMaster)
 - [BiometricAuthentication](https://github.com/iPhoNewsRO/BiometricAuthentication)
 - [ImpressiveNotifications](https://github.com/iPhoNewsRO/ImpressiveNotifications)

All icons used in ToDoList are designed by Icons8.com and available [here](http://icons8.com)

## License

RSToDoList is available under the GNU license. See the [LICENSE](https://github.com/iPhoNewsRO/ToDoList/blob/master/LICENSE) file for more info.