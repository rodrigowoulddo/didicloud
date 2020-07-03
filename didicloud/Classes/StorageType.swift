//
//  StorageType.swift
//  didicloud
//
//  Created by Rodrigo Giglio on 02/07/20.
//

import CloudKit

public enum StorageType {
    case publicStorage
    case privateStorage
    
    var database: CKDatabase {
        switch self {
            case .publicStorage: return CKContainer.default().publicCloudDatabase
            case .privateStorage: return CKContainer.default().privateCloudDatabase
        }
    }
}
