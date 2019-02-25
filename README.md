# RSToDoList

<p align="center">
  <img width="150" height="150" src="https://github.com/iPhoNewsRO/ToDoList/blob/master/Resources/icon.png" />
</p>

A simple To-do list app build for iOS 11+ in Swift 4.2 

## Main features
- [ ] Basic to do list features
	- [x] Persistent lists using Realm
	- [x] Add/delete items
	- [ ] Edit task properties
	- [x] Complete items
	- [x] Date/Time for items
	- [x] Sort options
- [ ] Theme support
- [ ] Tutorial/Onboarding
- [x] iCloud Kit support for syncing
- [ ] Push notifications for reminders
	- [ ] Synced push notifications between devices
- [ ] Optional lockdown with FaceID/TouchID or passcode

## How to run

1. Clone the repo
2. Run ```pod install``` in terminal to install required pods. Make sure you have (CocoaPods)[https://guides.cocoapods.org/using/getting-started.html] installed.
3. Turn on iCloud option in ```Capabilities``` and check ```CloudKit```. Turn on ```Background Modes``` and check ```Background fetch``` and ```Remote notification```.

## Live demo

Download [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) on your device and use [this](http://l0ng.in/todolist) link to get the latest build.

# To do

### v1.0
- [ ] Home page
	- [x] Tableview with All, Today, Tomorrow, Next 7 Days
	- [ ] Search bar
- [ ] Tasks view
	- [x] Custom cell
	- [x] Add item UI
	- [x] Sort
	- [x] Delete
	- [ ] Edit task
	- [ ] Search bar
- [x] Add task view
	- [x] Date picker
	- [x] Priority selector
	- [x] Comment viewer/editor
	- [x] Animations
- [ ] Settings page
	- [ ] Select start page
	- [ ] Manual iCloud Sync
	- [ ] Multi-Language support
	- [ ] Themes 
- [ ] Basic features
- [x] iCloud sync
- [ ] Push notifications

### v1.1
- [ ] Tutorial/Onboarding
- [ ] Theming 
- [ ] Multi-Language support
- [ ] Custom app icons
- [ ] Synced push notifications between devices
- [ ] Lockdown with FaceID/TouchID or passcode
- [ ] Rearrange tasks manually
- [ ] Smart dates (transform "'task name' today at 10:00" into a task with a date/time of today 10:00)
 
### Improvements
- [ ] Better hashtag integration in comments
- [ ] Delete comments
- [ ] Edit comments

### Known bugs
- [ ] IceCream lib won't sync task comments to cloudkit (https://github.com/caiyue1993/IceCream/issues/119)

## Frameworks used

 - LKAlertController
 - ActionSheetPicker-3.0
 - IceCream
 - UnderKeyboard
 - ActiveLabel
 - Realm & RealmSwift
 - [RSTextViewMaster](https://github.com/iPhoNewsRO/RSTextViewMaster)
 - CFNotify

## Extra credits

Icons by Icons8.com

## License

RSToDoList is available under the GNU license. See the [LICENSE](https://github.com/iPhoNewsRO/ToDoList/blob/master/LICENSE) file for more info.