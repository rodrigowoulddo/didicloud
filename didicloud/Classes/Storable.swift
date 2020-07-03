//
//  Storable.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit

public protocol StorableProtocol {
    static var reference: String { get }
    var record: CKRecord? { get }
    var id: CKRecord.ID? { get }
    init(_ record: CKRecord)
}

open class Storable: StorableProtocol {
    
    open class var reference: String { return "StorableObject" }
    public var record: CKRecord?
    public var id: CKRecord.ID?
        
    public required init(_ record: CKRecord) {
        
        self.record = record
        self.id = record.recordID
    }
        
    public init() { }
}
