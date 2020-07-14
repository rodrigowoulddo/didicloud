//
//  Storable.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit
import EVReflection

public protocol Referenciable {
    static var reference: String { get }
}

open class CKObject: CKDataObject {
    
    public required convenience init(_ record: CKRecord) {
        let dict = record.toDictionary()
        self.init(dictionary: dict)
        self.recordID = record.recordID
        self.recordType = record.recordType
        self.creationDate = record.creationDate ?? Date()
        self.creatorUserRecordID = record.creatorUserRecordID
        self.modificationDate = record.modificationDate ?? Date()
        self.lastModifiedUserRecordID = record.lastModifiedUserRecordID
        self.recordChangeTag = record.recordChangeTag
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(requiringSecureCoding: false)
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        self.encodedSystemFields = data as Data
    }
    
}


public protocol Storable: Referenciable & CKObject {
    
}

