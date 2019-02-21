//
//  HomeViewController.swift
//  ToDoList
//
//  Created by Radu Ursache on 20/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func setupUI() {
        super.setupUI()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "ToDoList", style: .done, target: self, action: #selector(self.titleButtonAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "settingsIcon")!, target: self, action: #selector(self.settingsButtonAction))
    }
    
    override func setupBindings() {
        super.setupBindings()
        
    }
    
    @objc func titleButtonAction() {
        self.showOK(title: "ToDoList", message: "A simple ToDoList written in Swift 4.2\n\nRanduSoft 2019")
    }
    
    @objc func settingsButtonAction() {
        
    }
}

