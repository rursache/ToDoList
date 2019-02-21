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
    
    func setupUI() {
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.barTintColor = Config.Colors.red
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
    }

    func setupBindings() {
        
    }
}
