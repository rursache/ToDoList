//
//  ThemeViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 16/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit

class ThemeViewController: BaseViewController {

	@IBOutlet weak var tableView: UITableView!
	
	let tableDataSource = Config.General.themes
	var doneCallback: (()->Void)?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        self.checkCurrentTheme()
    }
	
	override func setupBindings() {
		super.setupBindings()
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}

	override func setupUI() {
		super.setupUI()
		
		self.title = "SETTINGS_ITEM_ENTRY_THEMES".localized()
		
		self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
	}
	
	func checkCurrentTheme() {
		let currentThemeIndex = UserDefaults.standard.integer(forKey: Config.UserDefaults.theme)
		
		if self.tableDataSource.count > currentThemeIndex {
			self.tableView.selectRow(at: IndexPath(row: currentThemeIndex, section: 0), animated: true, scrollPosition: .none)
		}
	}
}

extension ThemeViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tableDataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath) as! ThemeTableViewCell
		
		let theme = self.tableDataSource[indexPath.row]
		
		cell.roundedView.backgroundColor = theme.color
		cell.nameLabel.text = theme.name
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let theme = self.tableDataSource[indexPath.row]
		
		UserDefaults.standard.set(Config.General.themes.firstIndex(of: theme), forKey: Config.UserDefaults.theme)
		NotificationCenter.default.post(name: Config.Notifications.themeUpdated, object: nil)
		
		UIApplication.shared.setAlternateIconName(theme.appIcon) { error in
			if let error = error {
				print(error.localizedDescription)
				Utils().showErrorToast(message: error.localizedDescription)
			}
		}
		
		self.doneCallback?()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
}
