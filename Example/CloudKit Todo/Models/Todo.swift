//
//  Todo.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 28/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit
import didicloud

class Todo: CKObject, Storable {
    
    static var reference: String = "Todo"
    
    /// Custom atributes
    var name: String = ""
    var simpleDescription: String?

}
