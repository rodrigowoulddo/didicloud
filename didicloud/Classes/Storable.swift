//
//  Storable.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit

public protocol Parser {
    func fromRecord(_ record: CKRecord) throws -> Storable
    func toRecord(_ storable: Storable) throws -> CKRecord
}

public enum ParsingError: Error { case DDCParsingEError }

public protocol Storable {
    
    static var reference: String { get }
    static var parser: Parser { get }
    
    var recordID: CKRecord.ID? { get }
}
