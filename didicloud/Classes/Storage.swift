//
//  Storage.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit

public struct Storage {
    
    private static let forbidenAttributes = ["id", "record"]

    public static func id(_ name: String) -> CKRecord.ID {
        return CKRecord.ID(recordName: name)
    }
    
    public static func getAll<T: Storable>(storageType: StorageType = .privateStorage, _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(recordType: T.reference, predicate: NSPredicate(value: true))
        
        storageType.database.perform(query, inZoneWith: nil) {
            results, error in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataRetrieval))
                return
            }
            
            guard let results = results else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            
            let values = results.map({ T.init($0) })
            completion(.success(values))
        }
    }
    
    public static func get<T: StorableProtocol>(storageType: StorageType = .privateStorage, recordID: CKRecord.ID, _ completion: @escaping (Result<T, Error>) -> Void) {
                
        storageType.database.fetch(withRecordID: recordID) {
            result, error in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataRetrieval))
                return
            }
            
            guard let result = result else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            let value = T.init(result)
            completion(.success(value))
        }
    }
    
    public static func create<T: StorableProtocol>(storageType: StorageType = .privateStorage, _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        let record = CKRecord(recordType: T.reference)
        
        for child in Mirror(reflecting: storable).children {
            if let key = child.label,
                !forbidenAttributes.contains(key)  {
                record.setValue(child.value, forKey: key)
            }
        }
                
        storageType.database.save(record) {
            (savedRecord, error) in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataInsertion))
                return
            }
            
            guard let savedRecord = savedRecord else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            completion(.success(T.init(savedRecord)))
        }
    }
    
    public static func update<T: StorableProtocol>(storageType: StorageType = .privateStorage, _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let record = storable.record else {
            completion(.failure(StorageError.cloudKitNullRecord))
            return
        }
        
        for child in Mirror(reflecting: storable).children {
            if let key = child.label,
                !forbidenAttributes.contains(key)  {
                record.setValue(child.value, forKey: key)
            }
        }
                
        storageType.database.save(record) {
            (savedRecord, error) in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataUpdate))
                return
            }
            
            guard let savedRecord = savedRecord else {
                completion(.failure(StorageError.cloudKitDataRetrieval))
                return
            }
            
            completion(.success(T.init(savedRecord)))
        }
    }
    
    public static func remove(storageType: StorageType = .privateStorage, _ recordID: String, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        
        let recordID = CKRecord.ID(recordName: recordID)
                
        storageType.database.delete(withRecordID: recordID) {
            (recordID, error) in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataRemoval))
                return
            }
            
            guard let recordID = recordID else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            completion(.success(recordID))
        }
    }
}
