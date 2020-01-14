//
//  TodayViewController.swift
//  ToDoListWidget
//
//  Created by Radu Ursache on 13/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {
        
	@IBOutlet weak var noTasksLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	var tasksDataSource: Results<TaskModel>!
	
	let cellSize: CGFloat = 45
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
		_ = RealmManager.init()
		
		self.loadData()
		
		self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
	
	func loadData() {
		self.tasksDataSource = RealmManager.sharedInstance.getTodayTasks().sorted(byKeyPath: "date", ascending: true)
		
		self.noTasksLabel.isHidden = self.tasksDataSource.count != 0
		self.tableView.isHidden = !self.noTasksLabel.isHidden
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
		
		self.tableView.reloadData()
	}
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		self.loadData()
        
        completionHandler(NCUpdateResult.newData)
    }
	
	@objc func completeTask(sender: UIButton) {
        RealmManager.sharedDelegate().completeTask(task: self.tasksDataSource[sender.tag])
        
        self.loadData()
    }
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		if activeDisplayMode == .expanded {
			preferredContentSize = CGSize(width: 0, height: self.cellSize * CGFloat(self.tasksDataSource.count) + 2)
		} else {
			preferredContentSize = maxSize
		}
	}
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tasksDataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath) as! WidgetCell
		
		cell.taskButton.tag = indexPath.row
        cell.taskButton.addTarget(self, action: #selector(self.completeTask), for: .touchUpInside)
		
		cell.taskLabel.text = self.tasksDataSource[indexPath.row].content
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.cellSize
	}
}
