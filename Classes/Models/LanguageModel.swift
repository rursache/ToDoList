//
//  LanguageModel.swift
//  ToDoList
//
//  Created by Radu Ursache on 25/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class LanguageModel: NSObject {
    var name = String()
    var code = String()
    
    override init() {
        super.init()
    }
    
    convenience init(name: String, code: String) {
        self.init()
        
        self.name = name
        self.code = code
    }
}
