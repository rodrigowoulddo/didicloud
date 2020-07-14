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
        
        let recordID = record.recordID
        let creatorUserRecordID = record.creatorUserRecordID
        
        guard
          let name = record["name"] as? String,
          let simpleDescription = record["simpleDescription"] as? String
        else { throw ParsingError.DDCParsingEError}
        
        let todo = Todo(recordID: recordID, creatorUserRecordID: creatorUserRecordID, name: name, simpleDescription: simpleDescription)
        return todo
    }
    
    func toRecord(_ storable: Storable) throws -> CKRecord {
        
        guard let todo = storable as? Todo else { throw ParsingError.DDCParsingEError }
        let record = CKRecord(recordType: Todo.reference)
        
        record.setValue(todo.name, forKey: "name")
        record.setValue(todo.simpleDescription, forKey: "simpleDescription")
        
        return record
    }
}
