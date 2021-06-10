//
//  RemindersViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 05/03/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import CoreActionSheetPicker

class RemindersViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentTask = TaskModel()
    var dataSource = [NotificationModel]()
    var currentEditingReminder = NotificationModel()
    
    var onCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView.reloadData()
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.title = "REMINDERS_TITLE".localized()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CLOSE".localized(), style: .done, target: self, action: #selector(self.closeAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addReminderAction))
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
		
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
    }
    
    func showDateTimePicker(edit: Bool) {
        let datePicker = ActionSheetDatePicker(title: "REMINDERS_SELECT_DATE_TIME".localized(), datePickerMode: .dateAndTime, selectedDate: edit ? self.currentEditingReminder.date as Date : Date(), doneBlock: { (actionSheet, selectedDate, origin) in
            guard let selectedDate = selectedDate as? Date else { return }
            
            if edit {
                Utils().removeNotification(notification: self.currentEditingReminder)
            }
            
            Utils().addNotification(task: self.currentTask, date: selectedDate, text: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.reloadData()
            }
        }, cancel: { (actionSheet) in
			
		}, origin: self.view)
        
		if #available(iOS 13.0, *) {
//			datePicker?.
			datePicker?.pickerBackgroundColor = .systemBackground
			datePicker?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
		}
        datePicker?.setDoneButton(UIBarButtonItem(title: "ADD".localized(), style: .done, target: self, action: nil))
        datePicker?.setCancelButton(UIBarButtonItem(title: "CANCEL".localized(), style: .done, target: self, action: nil))
        datePicker?.show()
    }
    
    @objc func addReminderAction() {
        self.showDateTimePicker(edit: false)
    }
    
    @objc func closeAction() {
        self.onCompletion?()
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentTask.availableNotifications().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.getIdentifier(), for: indexPath) as! ReminderTableViewCell
        
        let currentItem = self.currentTask.availableNotifications()[indexPath.row]
        
        let reminderDate = currentItem.date as Date
        
        if Calendar.current.isDateInToday(reminderDate) {
            cell.contentLabel.text = "TODAY".localized() + ", " + Config.General.timeFormatter().string(from: reminderDate)
        } else if Calendar.current.isDateInTomorrow(reminderDate) {
            cell.contentLabel.text = "TOMORROW".localized() + ", " + Config.General.timeFormatter().string(from: reminderDate)
        } else {
            cell.contentLabel.text = Config.General.dateFormatter().string(from: reminderDate)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.currentEditingReminder = self.currentTask.availableNotifications()[indexPath.row]
        
        self.showDateTimePicker(edit: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE".localized()) { (_, indexPath) in
            guard indexPath.row < self.currentTask.availableNotifications().count else { return }
            let reminder = self.currentTask.availableNotifications()[indexPath.row]
            
            Utils().removeNotification(notification: reminder)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.reloadData()
            }
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
