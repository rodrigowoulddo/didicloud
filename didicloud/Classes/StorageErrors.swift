//
//  StorageErrors.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation

public enum StorageError: LocalizedError {
        
    case DDCDataRetrieval
    case DDCDataInsertion
    case DDCDataRemoval
    case DDCDataUpdate
    case DDCNullReference
    case DDCNullRecord
    case DDCNullReturn
    case DDCParsingFailure

    public var errorDescription: String? {
        switch self {
        case .DDCDataRetrieval: return NSLocalizedString("Could not retrieve data from storage.", comment: "Error")
        case .DDCDataInsertion: return NSLocalizedString("Could not insert data into storage.", comment: "Error")
        case .DDCDataRemoval: return NSLocalizedString("Could not remove data from storage.", comment: "Error")
        case .DDCDataUpdate: return NSLocalizedString("Could not update data from storage.", comment: "Error")
        case .DDCNullReference: return NSLocalizedString("Could not work with a null resource ID.", comment: "Error")
        case .DDCNullRecord: return NSLocalizedString("Could not work with a null record.", comment: "Error")
        case .DDCNullReturn: return NSLocalizedString("Storage returned null for the operation.", comment: "Error")
        case .DDCParsingFailure: return NSLocalizedString("Could not parse CKRecord to object.", comment: "Error")
        }
    }
}
