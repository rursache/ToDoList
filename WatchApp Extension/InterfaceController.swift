//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by Radu Ursache on 14/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import WatchKit
import Foundation
import Realm
import RealmSwift
import WatchConnectivity

class InterfaceController: WKInterfaceController {

	@IBOutlet weak var tableView: WKInterfaceTable!
	@IBOutlet weak var noTasksLabel: WKInterfaceLabel!
	@IBOutlet weak var logoImageView: WKInterfaceImage!
	
	var wcSession: WCSession!
	var tableDataSource: Results<TaskModel>!
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		if WCSession.isSupported() {
		  self.wcSession = WCSession.default
		  self.wcSession.delegate = self
		  self.wcSession.activate()
		}
        
		self.setTitle(NSLocalizedString("WATCH_TITLE", comment: ""))
		
		self.loadTableData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		
		self.loadTableData()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	@IBAction func debugMenuAction() {
		self.loadTableData()
	}
	
	func loadTableData() {
		RealmManager.sharedInstance.watchInit()
		
		self.tableDataSource = RealmManager.sharedInstance.getTodayTasks().sorted(byKeyPath: "date", ascending: true)
		
		if self.tableDataSource.count != 0 {
			self.setTitle(NSLocalizedString("WATCH_TITLE", comment: "").replacingOccurrences(of: "{count}", with: "\(self.tableDataSource.count)")) 
		}
		
		self.noTasksLabel.setHidden(self.tableDataSource.count != 0)
		self.logoImageView.setHidden(self.tableDataSource.count != 0)
		
		self.tableView.setNumberOfRows(self.tableDataSource.count, withRowType: "taskRow")
		
		for item in self.tableDataSource {
			guard let rowController = self.tableView.rowController(at: self.tableDataSource.firstIndex(of: item)!) as? RowController else { return }
			
			rowController.taskTitleLabel.setText(item.content)
		}
	}
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		let taskId = self.tableDataSource[rowIndex].id
		
		self.completeTask(taskId: taskId)
	}
	
	func completeTask(taskId: String) {
		if !self.wcSession.isReachable {
			self.wcSession.activate()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				self.completeTask(taskId: taskId)
			}
			return
		}
		
		self.wcSession.sendMessage(["taskId": taskId], replyHandler: nil) { error in
			print("watchOS: failed to send task complete request")
		}
	}
	
	func processData(messageData: Data) {
		guard let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			print("watchOS: failed to get doc path")
			return
		}
		
		do {
			let realmDB = documentsPathURL.appendingPathComponent("db.realm")
			if FileManager.default.fileExists(atPath: realmDB.absoluteString) {
				try FileManager.default.removeItem(at: realmDB)
			}
			
			try messageData.write(to: realmDB)
			
			if FileManager.default.fileExists(atPath: realmDB.absoluteString) {
				self.loadTableData()
			}
		} catch {
			print("watchOS: failed to write")
		}
	}
}

extension InterfaceController: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("watchOS: \(activationState.rawValue)")
	}
	
	func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
		self.processData(messageData: messageData)
	}
	
	func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
		self.processData(messageData: messageData)
		
		replyHandler(messageData)
	}
}
