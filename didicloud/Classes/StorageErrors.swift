//
//  StorageErrors.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation

public enum StorageError: LocalizedError {
        
    case cloudKitDataRetrieval
    case cloudKitDataInsertion
    case cloudKitDataRemoval
    case cloudKitDataUpdate
    case cloudKitNullReference
    case cloudKitNullRecord
    case cloudKitNullReturn
    
    public var errorDescription: String? {
        switch self {
        case .cloudKitDataRetrieval: return NSLocalizedString("Could not retrieve data from storage.", comment: "Error")
        case .cloudKitDataInsertion: return NSLocalizedString("Could not insert data into storage.", comment: "Error")
        case .cloudKitDataRemoval: return NSLocalizedString("Could not remove data from storage.", comment: "Error")
        case .cloudKitDataUpdate: return NSLocalizedString("Could not update data from storage.", comment: "Error")
        case .cloudKitNullReference: return NSLocalizedString("Could not work with a null resource ID.", comment: "Error")
        case .cloudKitNullRecord: return NSLocalizedString("Could not work with a null record.", comment: "Error")
        case .cloudKitNullReturn: return NSLocalizedString("Storage returned null for the operation.", comment: "Error")
        }
    }
}
