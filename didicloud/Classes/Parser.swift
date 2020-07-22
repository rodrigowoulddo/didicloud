//
//  Parser.swift
//  didicloud
//
//  Created by Rodrigo Giglio on 22/07/20.
//

import CloudKit

public protocol Parser {
    func fromRecord(_ record: CKRecord) throws -> Storable
    func toRecord(_ storable: Storable) throws -> CKRecord
}

public enum ParsingError: Error { case DDCParsingError }
