//
//  BaseViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 21/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupBindings()
    }
    
    @objc func setupUI() {
        self.setupNavigationBar()
    }

    func setupBindings() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupUI), name: Config.Notifications.themeUpdated, object: nil)
    }
    
    func setupNavigationBar() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.barStyle = .black;
            self.navigationController?.navigationBar.barTintColor = Config.General.themes[UserDefaults.standard.integer(forKey: Config.UserDefaults.theme)].color
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.isTranslucent = false
            
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
    }
}
