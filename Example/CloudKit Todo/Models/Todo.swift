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

class Todo: Storable {
    
    public class override var reference: String { return "Todo" }
    
    /// Custom atributes
    var name: String
    var description: String?
    
    /// Storable init
    required init(_ record: CKRecord) {

        self.name = record["name"] as! String
        self.description = record["description"] as? String
        super.init(record)
    }
    
    /// Custom init
    init(name: String, description: String?) {
        self.name = name
        self.description = description
        super.init()
    }
}
