//
//  Storage.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit

public class Storage {
    
    private static let forbidenAttributes = ["id","record"]
    
    private static let privateStorage = CKContainer.default().privateCloudDatabase
    private static let publicStorage = CKContainer.default().publicCloudDatabase
    
    public static func id(_ name: String) -> CKRecord.ID {
        return CKRecord.ID(recordName: name)
    }

    public static func getAll<T: Storable>(privateData: Bool = true, _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(recordType: T.reference, predicate: NSPredicate(value: true))
        let storage = privateData ? privateStorage : publicStorage
        
        storage.perform(query, inZoneWith: nil) {
            results, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = results else {
                completion(.failure(StorageError.cloudKitDataRetrieve))
                return
            }
            
            let values = results.map({ T.init($0) })
            completion(.success(values))
        }
    }
    
    public static func get<T: Storable>(privateData: Bool = true, recordID: CKRecord.ID, _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(recordType: T.reference, predicate: NSPredicate(value: true))
        let storage = privateData ? privateStorage : publicStorage
        
        storage.perform(query, inZoneWith: nil) {
            results, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = results else {
                completion(.failure(StorageError.cloudKitDataRetrieve))
                return
            }
            
            let values = results.map({ T.init($0) })
            completion(.success(values))
        }
    }
    
    public static func create<T: Storable>(privateData: Bool = true, _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        let record = CKRecord(recordType: T.reference)
        
        for child in Mirror(reflecting: storable).children {
            if let key = child.label {
                if !forbidenAttributes.contains(key)  {
                    record.setValue(child.value, forKey: key)
                }
            }
        }
        
        let storage = privateData ? privateStorage : publicStorage
        
        storage.save(record) {
            (savedRecord, error) in
            
            guard let savedRecord = savedRecord else {
                
                completion(.failure(StorageError.cloudKitDataRetrieve))
                return
            }
            
            completion(.success(T.init(savedRecord)))
        }
    }
    
    public static func update<T: Storable>(privateData: Bool = true, _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let record = storable.record else {
            completion(.failure(StorageError.cloudKitDataRemoval))
            return
        }
        
        for child in Mirror(reflecting: storable).children {
            if let key = child.label {
                if !forbidenAttributes.contains(key)  {
                    record.setValue(child.value, forKey: key)
                }
            }
        }
        
        let storage = privateData ? privateStorage : publicStorage
        
        storage.save(record) {
            (savedRecord, error) in
            
            guard let savedRecord = savedRecord else {
                
                completion(.failure(StorageError.cloudKitDataRetrieve))
                return
            }
            
            completion(.success(T.init(savedRecord)))
        }
    }
    
    public static func remove(privateData: Bool = true, _ recordID: String, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {

        let recordID = CKRecord.ID(recordName: recordID)
        
        let storage = privateData ? privateStorage : publicStorage

        storage.delete(withRecordID: recordID) {
            (recordID, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let recordID = recordID else {
                completion(.failure(StorageError.cloudKitDataRemoval))
                return
            }
            
            completion(.success(recordID))
        }
    }
}
