//
//  HomeViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import IceCream
import CloudKit
import ActionSheetPicker_3_0

class HomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    
    var homeDataSource = [HomeItemModel]()
    var selectedItem = HomeItemModel()
    var shouldRedirectToPage = true
    var customIntervalDate: ActionSheetDateTimeRangePicker.DateRange?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Utils().userIsLoggedIniCloud() {
            Utils().showErrorToast(message: "You are not logged in iCloud. Your tasks won't be synced!".localized())
        } else {
            self.getUserFullName()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData()
        
        self.redirectToPageIfNeeded()
    }

    override func setupUI() {
        super.setupUI()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Config.General.appName, style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "settingsIcon")!, target: self, action: #selector(self.settingsButtonAction))
        
        self.addTaskButton.addTarget(self, action: #selector(self.addTaskButtonAction), for: .touchUpInside)
        
        Utils().themeView(view: self.addTaskButton)
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newCloudDataReceived(_:)), name: Notifications.cloudKitNewData.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.threeDTouchShortcutAction(_:)), name: Config.Notifications.threeDTouchShortcut, object: nil)
    }
    
    @objc func settingsButtonAction() {
        let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
        self.present(UINavigationController(rootViewController: settingsVC), animated: true, completion: nil)
    }
    
    func loadData() {
        let allCount = RealmManager.sharedInstance.getTasks().count
        let todayCount = RealmManager.sharedInstance.getTodayTasks().count
        let tomorrowCount = RealmManager.sharedInstance.getTomorrowTasks().count
        let weekCount = RealmManager.sharedInstance.getWeekTasks().count
        
        self.homeDataSource = [
            HomeItemModel(title: Config.General.startPageTitles[1], icon: "menu_all", listType: .All, count: allCount),
            HomeItemModel(title: Config.General.startPageTitles[2].localized(), icon: "menu_today", listType: .Today, count: todayCount),
            HomeItemModel(title: Config.General.startPageTitles[3].localized(), icon: "menu_tomorrow", listType: .Tomorrow, count: tomorrowCount),
            HomeItemModel(title: Config.General.startPageTitles[4].localized(), icon: "menu_week", listType: .Week, count: weekCount),
            HomeItemModel(title: Config.General.startPageTitles[5], icon: "menu_custom", listType: .Custom, count: -1)
                                ]
        
        self.tableView.reloadData()
        
        Utils().setBadgeNumber(badgeNumber: Config.Features.showTodayTasksAsBadgeNumber ? todayCount : 0)
    }
    
    func redirectToPageIfNeeded() {
        if !self.shouldRedirectToPage {
            return
        }
        
        self.shouldRedirectToPage = false
        
        let preference = UserDefaults.standard.integer(forKey: Config.UserDefaults.startPage)
        
        if preference == 0 {
            return // home page
        } else {
            self.selectedItem = self.homeDataSource[preference - 1]
        }
        
        self.performSegue(withIdentifier: "goToTasksVC", sender: self)
    }
    
    @objc func threeDTouchShortcutAction(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo, let option = userInfo["option"] as? Int else {
            return
        }
        
        self.navigationController?.popToViewController(self, animated: true)
        
        switch option {
        case 0:
            self.addTaskButtonAction()
            
            break
        case 1, 2, 3:
            self.selectedItem = self.homeDataSource[option - 1]
        default:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.performSegue(withIdentifier: "goToTasksVC", sender: self)
        }
    }
    
    @objc func newCloudDataReceived(_ notification: NSNotification) {
        print("New iCloud data received")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !UserDefaults.standard.bool(forKey: Config.UserDefaults.neverSyncedBefore) {
                UserDefaults.standard.set(true, forKey: Config.UserDefaults.neverSyncedBefore)
                
                Utils().showSuccessToast(message: "iCloud data synced succesfully!".localized())
            }
            
            guard let recordZone = notification.userInfo?["zoneId"] as? CKRecordZone.ID else {
                return
            }
            
            if recordZone.zoneName == "CommentModelsZone" || recordZone.zoneName == "NotificationModelsZone" {
                Utils().checkTasksForNilObjects()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadData()
                
                if recordZone.zoneName == "NotificationModelsZone" {
                    Utils().addAllExistingNotifications()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTasksVC" {
            guard let tasksVC = segue.destination as? TasksViewController else { return }

            tasksVC.title = self.selectedItem.title
            tasksVC.selectedType = self.selectedItem.listType
            tasksVC.customIntervalDate = self.customIntervalDate
        }
    }
    
    @objc func addTaskButtonAction() {
        let addTaskVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editTaskVC") as! EditTaskViewController
        addTaskVC.onCompletion = {
            self.loadData()
        }
        
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        navigationController.modalPresentationStyle = .custom
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func prepareCustomTaskList() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM YY"
        
        let picker = ActionSheetDateTimeRangePicker(
            title: "Select Date Interval".localized(),
            minimumDate: Date().next(days: -365),
            maximumDate: Date().next(days: 365),
            selectedRange: ActionSheetDateTimeRangePicker.DateRange(start: Date(), end: Date().next(hours: 24)),
            didSelectHandler: { (dateRange) in
                self.customIntervalDate = dateRange
                
                self.performSegue(withIdentifier: "goToTasksVC", sender: self)
            },
            didCancelHandler: nil,
            origin: self.view,
            minutesInterval: 60 * 24,
            minimumMultipleOfMinutesIntervalForRangeDuration: 1)
        
        picker.dateFormatter = formatter
        
        picker.show()
    }
    
    func getUserFullName() {
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error) in
            CKContainer.default().fetchUserRecordID { (record, error) in
                CKContainer.default().discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                    guard let firstName = userID?.nameComponents?.givenName,
                            let lastName = userID?.nameComponents?.familyName else {
                            UserDefaults.standard.removeObject(forKey: Config.UserDefaults.userFullName)
                                
                            return
                    }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: Config.UserDefaults.userFullName)
                })
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.getIdentifier(), for: indexPath) as! HomeTableViewCell
        
        let currentItem = self.homeDataSource[indexPath.row]
        
        cell.itemImageView.image = UIImage(named: currentItem.icon)
        cell.itemTitle.text = currentItem.title
        
        cell.itemCountLabel.text = String(currentItem.count)
        cell.itemCountLabel.isHidden = currentItem.count == -1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedItem = self.homeDataSource[indexPath.row]
        
        if self.selectedItem.count == -1 {
            self.prepareCustomTaskList()
        } else {
            self.performSegue(withIdentifier: "goToTasksVC", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
