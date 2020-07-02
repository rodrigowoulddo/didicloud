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
    
    /// Storable atributes
    public static let reference = "Todo"
    var record: CKRecord?
    var id: CKRecord.ID?
    
    /// Custom atributes
    var name: String
    var description: String?
    
    /// Storable init
    required init(_ record: CKRecord) {
        
        self.record = record
        self.id = record.recordID
        self.name = record["name"] as! String
        self.description = record["description"] as? String
    }
    
    /// Custom init
    init(name: String, description: String?) {
        self.name = name
        self.description = description
    }
}
