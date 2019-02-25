//
//  AddTaskViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import ActionSheetPicker_3_0
import UnderKeyboard
import LKAlertController
import RSTextViewMaster

class AddTaskViewController: BaseViewController {

    @IBOutlet weak var addTaskView: UIView!
    @IBOutlet weak var taskTitleTextView: RSTextViewMaster!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let keyboardObserver = UnderKeyboardObserver()
    var tempTask = TaskModel()
    var onCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RealmManager.sharedInstance.addTask(task: self.tempTask)

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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .done, target: self, action: #selector(self.cancelAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .done, target: self, action: #selector(self.saveAction))
        
        self.taskTitleTextView.text = ""
        self.taskTitleTextView.delegate = self
        self.taskTitleTextView.placeHolder = "Add a task".localized()
        self.taskTitleTextView.isAnimate = true
        self.taskTitleTextView.maxHeight = self.taskTitleTextView.frame.height * 6
        
        self.priorityButton.isHidden = !Config.Features.enablePriority
        self.commentButton.isHidden = !Config.Features.enableComments
        
        self.updateDateButtonTitle()
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        self.dateButton.addTarget(self, action: #selector(self.taskDateButtonAction), for: .touchUpInside)
        
        self.priorityButton.addTarget(self, action: #selector(self.priorityButtonAction), for: .touchUpInside)
        
        self.commentButton.addTarget(self, action: #selector(self.commentButtonAction), for: .touchUpInside)
        
        self.keyboardObserver.start()
        self.keyboardObserver.willAnimateKeyboard = { height in
            self.bottomConstraint.constant = height - 7 // padding to cover the bottom rounded corners
        }
        self.keyboardObserver.animateKeyboard = { height in
            self.addTaskView.layoutIfNeeded()
        }
    }
    
    func updateDateButtonTitle() {
        var buttonText = "Date".localized()
        var fontSize: CGFloat = 14
        
        if let taskDate = self.tempTask.date {
            buttonText = Config.General.dateFormatter().string(from: taskDate)
            
            fontSize = 11.5
        }
        
        self.dateButton.setTitle(buttonText, for: .normal)
        self.dateButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    @objc func taskDateButtonAction() {
        let datePicker = ActionSheetDatePicker(title: "Select date".localized(), datePickerMode: .date, selectedDate: self.tempTask.date ?? Date(), doneBlock: { (actionSheet, selectedDate, origin) in
            guard let selectedDate = selectedDate as? Date else { return }
            
            RealmManager.sharedInstance.changeTaskDate(task: self.tempTask, date: selectedDate)
            
            self.updateDateButtonTitle()
        }, cancel: { (actionSheet) in
            self.tempTask.date = nil
            self.updateDateButtonTitle()
        }, origin: self.dateButton)
        
        datePicker?.setDoneButton(UIBarButtonItem(title: "Save", style: .done, target: self, action: nil))
        datePicker?.setCancelButton(UIBarButtonItem(title: "No date", style: .done, target: self, action: nil))
        
        datePicker?.show()
    }
    
    @objc func priorityButtonAction() {
        let prioritySheet = ActionSheet(title: "Task priority", message: nil)
        
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
            self.setTaskPriority(priority: 10, title: "Priority")
        }
        
        prioritySheet.addAction("Cancel".localized(), style: .destructive)
        
        prioritySheet.presentIn(self)
        prioritySheet.show()
    }
    
    @objc func commentButtonAction() {
        let commentsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "commentsVC") as! CommentsViewController
        
        commentsVC.isNewTask = true
        commentsVC.currentTask = self.tempTask
        commentsVC.showKeyboardAtLoad = true
//        commentsVC.onCompletion = { comments in
//            
//        }
        
        self.present(UINavigationController(rootViewController: commentsVC), animated: true, completion: nil)
    }
    
    func setTaskPriority(priority: Int, title: String?) {
        RealmManager.sharedInstance.changeTaskPriority(task: self.tempTask, priority: priority)
        
        self.priorityButton.setTitle(title, for: .normal)
        
        if priority != 10 {
            self.priorityButton.setTitleColor(Config.General.priorityColors[priority - 1], for: .normal)
        } else {
            self.priorityButton.setTitleColor(UIColor.black, for: .normal)
        }
    }

    @objc func cancelAction() {
        RealmManager.sharedInstance.deleteTask(task: self.tempTask, soft: true)
        
        self.close()
    }

    @objc func saveAction() {
        let taskName = self.taskTitleTextView.text!
        
        if taskName.count == 0 {
            self.showError(message: "You must input a task to save it".localized())
            
            return
        }
        
        RealmManager.sharedInstance.changeTaskContent(task: self.tempTask, content: taskName)
        
        self.close()
    }
    
    func close() {
        self.closeKeyboard()
        
        self.onCompletion?()
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func closeKeyboard() {
        self.view.endEditing(true)
    }
}

extension AddTaskViewController: RSTextViewMasterDelegate, UITextViewDelegate {
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
