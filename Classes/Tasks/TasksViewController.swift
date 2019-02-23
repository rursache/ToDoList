//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit
import RealmSwift
import LKAlertController
import IceCream

enum SortType: String {
    case Date = "date"
    case Priority = "priority"
}

class TasksViewController: BaseViewController {
    
    var selectedType: HomeItemModel.ListType = .All
    var tasksDataSource: Results<TaskModel>!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    
    var currentSortType: SortType = .Date
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setDefaultSorting()
        self.loadData()
    }
    
    func loadData() {
        if selectedType == .All {
            self.tasksDataSource = RealmManager.sharedInstance.getTasks()
        } else if selectedType == .Today {
            self.tasksDataSource = RealmManager.sharedInstance.getTodayTasks()
        } else if selectedType == .Tomorrow {
            self.tasksDataSource = RealmManager.sharedInstance.getTomorrowTasks()
        } else if selectedType == .Week {
            self.tasksDataSource = RealmManager.sharedInstance.getWeekTasks()
        }
        
        self.sortDataSource(ascending: true)
    }

    override func setupUI() {
        super.setupUI()
        
        self.addTaskButton.addTarget(self, action: #selector(self.addTaskButtonAction), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "sortIcon")!, target: self, action: #selector(self.sortButtonAction))
        
        Utils().themeView(view: self.addTaskButton)
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newCloudDataReceived), name: Notifications.cloudKitNewData.name, object: nil)
    }

    @objc func newCloudDataReceived() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadData()
        }
    }
    
    @objc func addTaskButtonAction() {
        let addTaskVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addTaskVC") as! AddTaskViewController
        addTaskVC.onCompletion = {
            self.loadData()
        }
        
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        navigationController.modalPresentationStyle = .custom
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func sortDataSource(ascending: Bool) {
        self.tasksDataSource = self.tasksDataSource.sorted(byKeyPath: self.currentSortType.rawValue, ascending: ascending)
        
        self.tableView.reloadData()
    }
    
    @objc func sortButtonAction() {
        let sortSheet = ActionSheet(title: "Sort tasks".localized(), message: nil)
        
        for sortOption in Config.General.sortTitles {
            sortSheet.addAction(sortOption, style: .default) { (action) in
                let itemIndex = Config.General.sortTitles.index(of: sortOption)!
                
                if itemIndex == 0 || itemIndex == 1 {
                    self.currentSortType = .Date
                } else if itemIndex == 2 || itemIndex == 3 {
                    self.currentSortType = .Priority
                }
                
                self.sortDataSource(ascending: (itemIndex % 2 == 0))
            }
        }
        
        sortSheet.addAction("Cancel", style: .destructive)
        
        sortSheet.presentIn(self)
        sortSheet.show()
    }
    
    func setDefaultSorting() {
        if selectedType == .All {
            self.currentSortType = .Priority
        } else if selectedType == .Today {
            self.currentSortType = .Date
        } else if selectedType == .Tomorrow {
            self.currentSortType = .Date
        } else if selectedType == .Week {
            self.currentSortType = .Date
        }
    }
    
    func showTaskPrioritySheet(task: TaskModel) {
        let prioritySheet = ActionSheet(title: "Task priority", message: nil)
        
        prioritySheet.addAction(Config.General.priorityTitles[0], style: .default) { (action) in
            self.changeTaskPriority(task: task, priority: 1)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[1], style: .default) { (action) in
            self.changeTaskPriority(task: task, priority: 2)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[2], style: .default) { (action) in
            self.changeTaskPriority(task: task, priority: 3)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[3], style: .default) { (action) in
            self.changeTaskPriority(task: task, priority: 4)
        }
        
        prioritySheet.addAction(Config.General.priorityTitles[4], style: .default) { (action) in
            self.changeTaskPriority(task: task, priority: 10)
        }
        
        prioritySheet.addAction("Cancel".localized(), style: .destructive)
        
        prioritySheet.presentIn(self)
        prioritySheet.show()
    }
    
    func changeTaskPriority(task: TaskModel, priority: Int) {
        RealmManager.sharedDelegate().changeTaskPriority(object: task, priority: priority)
        
        self.loadData()
        
        Utils().showSuccessToast(message: "Task priority updated!".localized())
    }
    
    func completeTask(task: TaskModel) {
        RealmManager.sharedDelegate().completeTask(object: task)
        
        self.loadData()
        
        Utils().showSuccessToast(message: "Task completed!".localized())
    }
    
    func deleteTask(task: TaskModel) {
        RealmManager.sharedDelegate().deleteTask(object: task, soft: true)
        
        self.loadData()
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasksDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.getIdentifier(), for: indexPath) as! TaskTableViewCell
        
        let currentItem = self.tasksDataSource[indexPath.row]
        
        cell.taskNameLabel.text = currentItem.content
        
        cell.checkBoxButton.addAction {
            // test with multiple tasks, after cellForRowAt was called multiple times
            self.completeTask(task: currentItem)
        }
        
        if let taskDate = currentItem.date {
            cell.taskDateLabel.text = Config.General.dateFormatter().string(from: taskDate)
            cell.taskDateLabel.isHidden = false
        } else {
            cell.taskDateLabel.isHidden = true
        }
        
        if currentItem.priority != 10 && Config.Features.enablePriority {
            cell.priorityButton.setTitle(Config.General.priorityTitles[currentItem.priority - 1], for: .normal)
            cell.priorityButton.setTitleColor(Config.General.priorityColors[currentItem.priority - 1], for: .normal)
            cell.priorityButton.isHidden = false
        } else {
            cell.priorityButton.isHidden = true
        }
        
        if currentItem.comments.count > 0, Config.Features.enableComments {
            cell.commentsButton.setTitle("\(currentItem.comments.count)", for: .normal)
            cell.commentsButton.isHidden = false
        } else {
            cell.commentsButton.isHidden = true
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentItem = self.tasksDataSource[indexPath.row]
        
        let taskOptionsSheet = ActionSheet(title: "Task options".localized(), message: nil)
        
        taskOptionsSheet.addAction("Complete".localized(), style: .default) { (action) in
            self.completeTask(task: currentItem)
        }
        
        taskOptionsSheet.addAction("Edit".localized(), style: .default) { (action) in
            // to do
        }
        
        taskOptionsSheet.addAction("Change Priority".localized(), style: .default) { (action) in
            self.showTaskPrioritySheet(task: currentItem)
        }
        
        taskOptionsSheet.addAction("Comments".localized(), style: .default) { (action) in
            let commentsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "commentsVC") as! CommentsViewController
            
            commentsVC.isNewTask = false
            commentsVC.currentTask = currentItem
            commentsVC.showKeyboardAtLoad = false
            commentsVC.onCompletion = { comments in
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            self.present(UINavigationController(rootViewController: commentsVC), animated: true, completion: nil)
        }
        
        taskOptionsSheet.addAction("Cancel".localized(), style: .destructive)
        
        taskOptionsSheet.presentIn(self)
        taskOptionsSheet.show()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete".localized()) { (_, indexPath) in
            guard indexPath.row < self.tasksDataSource.count else { return }
            let task = self.tasksDataSource[indexPath.row]
            
            self.deleteTask(task: task)
        }
        return [deleteAction]
    }
}
