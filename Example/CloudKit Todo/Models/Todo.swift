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

struct Todo: Storable {
    
    /// Static attributes
    static var reference: String = "Todo"
    static var parser: Parser = TodoParser()
    
    /// Storable attributes
    var recordID: CKRecord.ID?
    
    /// Custom attributes
    var name: String
    var simpleDescription: String?

}
