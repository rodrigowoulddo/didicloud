//
//  StorageType.swift
//  didicloud
//
//  Created by Rodrigo Giglio on 02/07/20.
//

import CloudKit

public enum StorageType {
    case publicStorage(customContainer: String? = nil)
    case privateStorage(customContainer: String? = nil)
    
    var container: String? {
        
        switch self  {
        case
        .publicStorage(let customContainer),
        .privateStorage(let customContainer):
            
            return customContainer
        }
    }
    
    var database: CKDatabase {
        switch self {
        case .publicStorage(let customContainer):
            
            if let customContainer = customContainer {
                
                return CKContainer(identifier: customContainer).publicCloudDatabase
                
            } else {
                
                return CKContainer.default().publicCloudDatabase
                
            }
        case .privateStorage(let customContainer):


            if let customContainer = customContainer {
                
                return CKContainer(identifier: customContainer).privateCloudDatabase
                
            } else {
                
                return CKContainer.default().privateCloudDatabase
                
            }
        }
    }
}
