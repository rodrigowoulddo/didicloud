//
//  TodoParser.swift
//  Didicloud-Example
//
//  Created by Rodrigo Giglio on 14/07/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import didicloud
import CloudKit

class TodoParser: Parser {
    
    func fromRecord(_ record: CKRecord) throws -> Storable {
        
        let recordName = record.recordID.recordName
        
        guard
          let name = record["name"] as? String,
          let simpleDescription = record["simpleDescription"] as? String
        else { throw ParsingError.DDCParsingError}
        
        let todo = Todo(recordName: recordName, name: name, simpleDescription: simpleDescription)
        return todo
    }
    
    func toRecord(_ storable: Storable) throws -> CKRecord {
        
        guard let todo = storable as? Todo else { throw ParsingError.DDCParsingError }
        
        let record = Storage.record(from: todo)
        
        record.setValue(todo.name, forKey: "name")
        record.setValue(todo.simpleDescription, forKey: "simpleDescription")
        
        return record
    }
}
