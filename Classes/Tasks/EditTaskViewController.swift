//
//  EditTaskViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CoreActionSheetPicker
import UnderKeyboard
import LKAlertController
import RSTextViewMaster

class EditTaskViewController: BaseViewController {

	@IBOutlet weak var addTaskView: UIView!
    @IBOutlet weak var taskTitleTextView: RSTextViewMaster!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var remindersButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
	var parentType: HomeItemModel.ListType = .All
    let keyboardObserver = UnderKeyboardObserver()
    var tempTask = TaskModel()
    var onCompletion: (() -> Void)?
    var mustShowAlert: ((String) -> ())?
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.editMode {
            self.tempTask.isDeleted = true
            RealmManager.sharedInstance.addTask(task: self.tempTask)
			
			// set task date and time to now if you're coming from Today screen AND the next hour will be today as well
			if self.parentType == .Today && Calendar.current.isDateInToday(Date().next(hours: 1)) {
				RealmManager.sharedInstance.changeTaskDate(task: self.tempTask, date: Date().next(hours: 1))
				self.updateDateButtonTitle()
			}
        } else {
            self.loadExistingTaskData()
        }

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.taskTitleTextView.becomeFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        if self.editMode {
            self.title = "EDIT_TASKS_EDIT_TASK".localized()
        } else {
            self.title = "EDIT_TASKS_ADD_TASK".localized()
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CANCEL".localized(), style: .done, target: self, action: #selector(self.cancelAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".localized(), style: .done, target: self, action: #selector(self.saveAction))
        
        self.taskTitleTextView.text = ""
        self.taskTitleTextView.delegate = self
        self.taskTitleTextView.placeHolder = "EDIT_TASKS_TASK_CONTENT".localized()
        self.taskTitleTextView.isAnimate = true
        self.taskTitleTextView.maxHeight = self.taskTitleTextView.frame.height * 6
        
        self.priorityButton.isHidden = !Config.Features.enablePriority
        if !Config.Features.enableComments || self.editMode {
            self.commentButton.isHidden = true
        }
        
        self.remindersButton.isHidden = self.editMode
        
        self.updateDateButtonTitle()
        self.updateCommentsButton()
        self.updateRemindersButton()
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        self.dateButton.addTarget(self, action: #selector(self.taskDateButtonAction), for: .touchUpInside)
        self.priorityButton.addTarget(self, action: #selector(self.priorityButtonAction), for: .touchUpInside)
        self.commentButton.addTarget(self, action: #selector(self.commentButtonAction), for: .touchUpInside)
        self.remindersButton.addTarget(self, action: #selector(self.remindersButtonAction), for: .touchUpInside)
        
        self.keyboardObserver.start()
        self.keyboardObserver.willAnimateKeyboard = { height in
            self.bottomConstraint.constant = height - 7 // padding to cover the bottom rounded corners
        }
        self.keyboardObserver.animateKeyboard = { height in
            self.addTaskView.layoutIfNeeded()
        }
    }
    
    func loadExistingTaskData() {
        self.taskTitleTextView.text = self.tempTask.content
        self.taskTitleTextView.layoutIfNeeded()
        
        let currentPriority = self.tempTask.priority
        self.setTaskPriority(priority: currentPriority, title: currentPriority != 10 ? Config.General.priorityTitles[currentPriority-1] : "Priority".localized())
        
        self.updateDateButtonTitle()
        self.updateCommentsButton()
        self.updateRemindersButton()
    }
    
    func updateDateButtonTitle() {
        var buttonText = "EDIT_TASKS_DATE_TIME".localized()
        var fontSize: CGFloat = 13
        
        if let taskDate = self.tempTask.date {
            if Calendar.current.isDateInToday(taskDate) {
                buttonText = "TODAY".localized() + ", " + Config.General.timeFormatter().string(from: taskDate)
            } else if Calendar.current.isDateInTomorrow(taskDate) {
                buttonText = "TOMORROW_SHORT".localized() + ", " + Config.General.timeFormatter().string(from: taskDate)
            } else {
                buttonText = Config.General.dateFormatter().string(from: taskDate)
            }
            
            fontSize = 11.5
        }
        
        self.dateButton.setTitle(buttonText, for: .normal)
        self.dateButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    func updateCommentsButton() {
        self.commentButton.setTitle("\(self.tempTask.availableComments().count)", for: .normal)
    }
    
    func updateRemindersButton() {
        self.remindersButton.setTitle("\(self.tempTask.availableNotifications().count)", for: .normal)
    }
    
    @objc func taskDateButtonAction() {
        let datePicker = ActionSheetDatePicker(title: "REMINDERS_SELECT_DATE_TIME".localized(), datePickerMode: .dateAndTime, selectedDate: self.tempTask.date ?? Date(), doneBlock: { (actionSheet, selectedDate, origin) in
            guard let selectedDate = selectedDate as? Date else { return }
            
            RealmManager.sharedInstance.changeTaskDate(task: self.tempTask, date: selectedDate)
            
            self.updateDateButtonTitle()
        }, cancel: { (actionSheet) in
            RealmManager.sharedInstance.changeTaskDate(task: self.tempTask, date: nil)
            
            self.updateDateButtonTitle()
        }, origin: self.dateButton)
        
		if #available(iOS 13.0, *) {
			datePicker?.pickerBackgroundColor = .systemBackground
			datePicker?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
		}
        datePicker?.setDoneButton(UIBarButtonItem(title: "SAVE".localized(), style: .done, target: self, action: nil))
        datePicker?.setCancelButton(UIBarButtonItem(title: "EDIT_TASKS_NO_DATE".localized(), style: .done, target: self, action: nil))
        
        datePicker?.show()
    }
    
    @objc func priorityButtonAction() {
        let prioritySheet = ActionSheet(title: "EDIT_TASKS_TASK_PRIORITY".localized(), message: nil)
		prioritySheet.setPresentingSource(self.priorityButton)
        
        prioritySheet.addAction(Config.General.priorityTitles[0], style: .default) { (action) in
            self.setTaskPriority(priority: 1, title: action?.title)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[1], style: .default) { (action) in
            self.setTaskPriority(priority: 2, title: action?.title)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[2], style: .default) { (action) in
            self.setTaskPriority(priority: 3, title: action?.title)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[3], style: .default) { (action) in
            self.setTaskPriority(priority: 4, title: action?.title)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[4], style: .default) { (action) in
            self.setTaskPriority(priority: 10, title: "EDIT_TASKS_PRIORITY".localized())
        }
        
        prioritySheet.addAction("CANCEL".localized(), style: .cancel)
        
        prioritySheet.presentIn(self)
        prioritySheet.show()
    }
    
    @objc func remindersButtonAction() {
        let remindersVC = Utils().getViewController(viewController: .reminders) as! RemindersViewController
        remindersVC.currentTask = self.tempTask
        remindersVC.onCompletion = {
            self.updateRemindersButton()
			self.taskTitleTextView.becomeFirstResponder()
        }
		
		self.present(UINavigationController(rootViewController: remindersVC), animated: true) {
			self.taskTitleTextView.resignFirstResponder()
		}
    }
    
    @objc func commentButtonAction() {
        let commentsVC = Utils().getViewController(viewController: .comments) as! CommentsViewController
        
        commentsVC.currentTask = self.tempTask
        commentsVC.showKeyboardAtLoad = true
        commentsVC.onCompletion = {
            self.updateCommentsButton()
        }
        
        self.present(UINavigationController(rootViewController: commentsVC), animated: true, completion: nil)
    }
    
    func setTaskPriority(priority: Int, title: String?) {
        RealmManager.sharedInstance.changeTaskPriority(task: self.tempTask, priority: priority)
        
        self.priorityButton.setTitle(title, for: .normal)
        
        if priority != 10 {
            self.priorityButton.setTitleColor(Config.General.priorityColors[priority - 1], for: .normal)
        } else {
			if #available(iOS 13.0, *) {
				self.priorityButton.setTitleColor(UIColor.label, for: .normal)
			} else {
				self.priorityButton.setTitleColor(UIColor.black, for: .normal)
			}
        }
    }

    @objc func cancelAction() {
        if !self.editMode {
            RealmManager.sharedInstance.deleteTask(task: self.tempTask, soft: true)
        }
        
        self.close()
    }

    @objc func saveAction() {
        let taskName = self.taskTitleTextView.text!
        
        if taskName.count == 0 {
            self.showError(message: "EDIT_TASKS_NO_TASK_NAME_ERROR".localized())
            
            return
        }
        
        RealmManager.sharedInstance.changeTaskContent(task: self.tempTask, content: taskName)
        
        // add the default notification for a new task
        if !self.editMode && !UserDefaults.standard.bool(forKey: Config.UserDefaults.disableAutoReminders) {
            if let taskDate = self.tempTask.date {
                Utils().addNotification(task: self.tempTask, date: taskDate.next(minutes: Config.General.notificationDefaultDelayForNotifications), text: nil)
            }
        }
        
        if !self.editMode {
            RealmManager.sharedInstance.softUnDeleteTask(task: self.tempTask)
        }
        
        self.close {
            // check if a helpful prompt must be shown or not
            if self.parentType != .All && self.tempTask.date == nil && UserDefaults.standard.bool(forKey: Config.UserDefaults.helpPrompts) {
                self.mustShowAlert?("EDIT_TASKS_CHANGED_ERROR".localized().replacingOccurrences(of: "{replace}", with: self.editMode ? "EDIT_TASKS_UPDATED".localized() : "EDIT_TASKS_ADDED".localized()))
            }
        }
    }
    
    func close(completion: (() -> Void)? = nil) {
        self.closeKeyboard()
        
        self.onCompletion?()
        if Utils().isIpad() {
            NotificationCenter.default.post(name: Config.Notifications.shouldReloadData, object: nil)
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func closeKeyboard() {
        self.view.endEditing(true)
    }
}

extension EditTaskViewController: RSTextViewMasterDelegate, UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // to do
        // limit to 10 rows
        
        return true
    }
    
    func growingTextView(growingTextView: RSTextViewMaster, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
    
    func growingTextView(growingTextView: RSTextViewMaster, didChangeHeight height: CGFloat) {
        
    }
}
