//
//  StorageErrors.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation

public enum StorageError: Error {
    
    case cloudKitDataRetrieve
    case cloudKitDataInsertion
    case cloudKitDataRemoval
    case cloudKitDataUpdate
    case cloudKitNullReference

}
