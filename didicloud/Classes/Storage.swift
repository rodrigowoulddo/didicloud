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

    public static func newID() -> CKRecord.ID {
        return CKRecord.ID(recordName: UUID().uuidString)
    }
    
    /// Returns the current user icloud ID
    /// - Parameter completion: Result object containing the user icloud ID or an error
    public static func getUserRecordID(_ completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        CKContainer.default().fetchUserRecordID { (result, error) in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataRetrieval))
                return
            }
            
            guard let result = result else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            completion(.success(result))
            
        }
    }
    
    /// Fetch all records of T owned by current user
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    public static func fetchRecordsByUser<T: Storable>(storageType: StorageType = .privateStorage, _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        getUserRecordID { (result) in
            switch result {
            case .success(let recordID):
                let query = CKQuery(
                    recordType: T.reference,
                    predicate: NSPredicate(format: "creatorUserRecordID == %@", recordID)
                )
                
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
                    
                    var values: [T] = []
                    for record in results {
                        guard let value = try? T.parser.fromRecord(record) as? T else {
                            completion(.failure(StorageError.parsingFailure))
                            return
                        }
                        values.append(value)
                    }
                    
                    completion(.success(values))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch all records of T
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
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
            
            
            var values: [T] = []
            for record in results {
                guard let value = try? T.parser.fromRecord(record) as? T else {
                    completion(.failure(StorageError.parsingFailure))
                    return
                }
                values.append(value)
            }
            
            completion(.success(values))
        }
    }
    
    /// Fetch the record with the ID
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordID: The UUID of the record in the database
    ///   - completion: Result object containing the fetched record or an error
    public static func get<T: Storable>(storageType: StorageType = .privateStorage, recordID: CKRecord.ID, _ completion: @escaping (Result<T, Error>) -> Void) {
                
        storageType.database.fetch(withRecordID: recordID) {
            result, error in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataRetrieval))
                return
            }
            
            guard let record = result else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            guard let value = try? T.parser.fromRecord(record) as? T else {
                completion(.failure(StorageError.parsingFailure))
                return
            }
            
            completion(.success(value))
        }
    }
    
    /// Create a record in the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - storable: The Storable object to  e inserted
    ///   - completion: Result object containing the created record  or an error
    public static func create<T: Storable>(storageType: StorageType = .privateStorage, _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let record = try? T.parser.toRecord(storable) else {
            return completion(.failure(StorageError.parsingFailure))
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
            
            guard let value = try? T.parser.fromRecord(savedRecord) as? T else {
                completion(.failure(StorageError.parsingFailure))
                return
            }
            
            completion(.success(value))
        }
    }
    
    /// Updates a record in the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - storable: The Storable object to  e updated
    ///   - completion: Result object containing the updated record or an error
    public static func update<T: Storable>(storageType: StorageType = .privateStorage, _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let record = try? T.parser.toRecord(storable) else {
            return completion(.failure(StorageError.parsingFailure))
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
            
            guard let value = try? T.parser.fromRecord(savedRecord) as? T else {
                completion(.failure(StorageError.parsingFailure))
                return
            }
            
            completion(.success(value))
        }
    }
    
    /// Removes a record from the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordID: The UUID of the record in the database
    ///   - completion: Result object the deleted record ID or an error
    public static func remove(storageType: StorageType = .privateStorage, _ recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
                
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
    
    /// Removes multiple records from the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordIDs: The UUID's in the database
    ///   - completion: Result object the deleted record ID's or an error
    public static func remove(storageType: StorageType = .privateStorage, _ recordIDs: [CKRecord.ID], completion: @escaping (Result<[CKRecord.ID], Error>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        
        operation.modifyRecordsCompletionBlock = {
            (_, deletedRecordIDs, error) in
            
            if error != nil {
                completion(.failure(StorageError.cloudKitDataRemoval))
                return
            }
            
            guard let recordIDs = deletedRecordIDs else {
                completion(.failure(StorageError.cloudKitNullReturn))
                return
            }
            
            completion(.success(recordIDs))
        }
        
        storageType.database.add(operation)
    }
    
    /// Removes all records of type T
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - type: The type of the record
    ///   - completion: Result object the deleted record ID's or an error
    public static func removeAll<T: Storable>(storageType: StorageType = .privateStorage, type: T.Type, completion: @escaping (Result<[CKRecord.ID], Error>) -> Void) {
        
        getAll(storageType: storageType) { (result: Result<[T], Error>) in
            
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let values):
                
                guard let recordIDs = values.map({ $0.recordID }) as? [CKRecord.ID] else {
                    completion(.failure(StorageError.cloudKitNullRecord))
                    return
                }
                
                remove(storageType:storageType, recordIDs) {
                    result in
                    
                    switch result {
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .success(let recordIDs):
                        completion(.success(recordIDs))
                    }
                }
            }
        }
    }
    
    /// Removes all records of type T owned by current user
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - type: The type of the record
    ///   - completion: Result object the deleted record ID's or an error
    public static func removeAllbyUser<T: Storable>(storageType: StorageType = .privateStorage, type: T.Type, completion: @escaping (Result<[CKRecord.ID], Error>) -> Void) {
        
        fetchRecordsByUser(storageType: storageType) { (result: Result<[T], Error>) in
            
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let values):
                
                guard let recordIDs = values.map({ $0.recordID }) as? [CKRecord.ID] else {
                    completion(.failure(StorageError.cloudKitNullRecord))
                    return
                }
                
                remove(storageType:storageType, recordIDs) {
                    result in
                    
                    switch result {
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .success(let recordIDs):
                        completion(.success(recordIDs))
                    }
                }
            }
        }
    }
}
