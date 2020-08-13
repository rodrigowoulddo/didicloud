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
    
    /// Returns an CKRecordID for the given recordName
    /// - Parameter completion: Result object containing the user icloud ID or an error
    public static func id(from recordName: String) -> CKRecord.ID {
        return CKRecord.ID(recordName: recordName)
    }
    
    /// Returns a record for the passing Storable object. If the objects has a recordName, it will be preserved.
    /// - Parameter storable: Result CKRecord object from the Storable Object
    public static func record<T: Storable>(from storable: T) -> CKRecord {
        
        let record: CKRecord
        
        if let recordName = storable.recordName {
            
            record = CKRecord(recordType: T.reference, recordID: CKRecord.ID(recordName: recordName))
            
        } else {
            
            record = CKRecord(recordType: T.reference)
        }
        
        return record
    }
    
    /// Returns the current user icloud ID
    /// - Parameter completion: Result object containing the user icloud ID or an error
    public static func getUserRecordID(customContainer: String? = nil, _ completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        
        let container: CKContainer
        if let customContainer = customContainer { container = CKContainer(identifier: customContainer) }
        else { container = CKContainer.default() }
        
        container.fetchUserRecordID { (result, error) in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataRetrieval))
                return
            }
            
            guard let result = result else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            completion(.success(result))
            
        }
    }
    
    /// Fetch all records of T owned by current user
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    public static func fetchRecordsByUser<T: Storable>(storageType: StorageType = .privateStorage(), _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        getUserRecordID(customContainer: storageType.container) { (result) in
            switch result {
            case .success(let recordID):
                let query = CKQuery(
                    recordType: T.reference,
                    predicate: NSPredicate(format: "creatorUserRecordID == %@", recordID)
                )
                
                storageType.database.perform(query, inZoneWith: nil) {
                    results, error in
                    
                    if error != nil {
                        completion(.failure(StorageError.DDCDataRetrieval))
                        return
                    }
                    
                    guard let results = results else {
                        completion(.failure(StorageError.DDCNullReturn))
                        return
                    }
                    
                    var values: [T] = []
                    for record in results {
                        guard let value = try? T.parser.fromRecord(record) as? T else {
                            completion(.failure(StorageError.DDCParsingFailure))
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
    
    /// Fetch records using a predicate String
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    ///   - predicate: Predicate string
    public static func get<T: Storable>(storageType: StorageType = .privateStorage(), predicate: NSPredicate,  _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(
            recordType: T.reference,
            predicate: predicate
        )
        
        storageType.database.perform(query, inZoneWith: nil) {
            results, error in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataRetrieval))
                return
            }
            
            guard let results = results else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            var values: [T] = []
            for record in results {
                guard let value = try? T.parser.fromRecord(record) as? T else {
                    completion(.failure(StorageError.DDCParsingFailure))
                    return
                }
                values.append(value)
            }
            
            completion(.success(values))
        }
    }
    
    /// Fetch all records of T
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    public static func getAll<T: Storable>(storageType: StorageType = .privateStorage(), _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(recordType: T.reference, predicate: NSPredicate(value: true))
        
        storageType.database.perform(query, inZoneWith: nil) {
            results, error in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataRetrieval))
                return
            }
            
            guard let results = results else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            
            var values: [T] = []
            for record in results {
                guard let value = try? T.parser.fromRecord(record) as? T else {
                    completion(.failure(StorageError.DDCParsingFailure))
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
    public static func get<T: Storable>(storageType: StorageType = .privateStorage(), recordName: String, _ completion: @escaping (Result<T, Error>) -> Void) {
                
        let recordID = CKRecord.ID(recordName: recordName)
        storageType.database.fetch(withRecordID: recordID) {
            result, error in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataRetrieval))
                return
            }
            
            guard let record = result else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            guard let value = try? T.parser.fromRecord(record) as? T else {
                completion(.failure(StorageError.DDCParsingFailure))
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
    public static func create<T: Storable>(storageType: StorageType = .privateStorage(), _ storable: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let record = try? T.parser.toRecord(storable) else {
            return completion(.failure(StorageError.DDCParsingFailure))
        }
                
        storageType.database.save(record) {
            (savedRecord, error) in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataInsertion))
                return
            }
            
            guard let savedRecord = savedRecord else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            guard let value = try? T.parser.fromRecord(savedRecord) as? T else {
                completion(.failure(StorageError.DDCParsingFailure))
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
    public static func update<T: Storable>(storageType: StorageType = .privateStorage(), _ storable: T, _  completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let record = try? T.parser.toRecord(storable) else {
            completion(.failure(StorageError.DDCParsingFailure))
            return
        }
                
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        
        operation.modifyRecordsCompletionBlock = {
            (updatedRecords, _, error) in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataUpdate))
                return
            }
            
            guard let recordName = updatedRecords?.first?.recordID.recordName else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            completion(.success(recordName))
        }
        
        storageType.database.add(operation)
    }
    
    /// Removes a record from the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordID: The UUID of the record in the database
    ///   - completion: Result object the deleted record ID or an error
    public static func remove(storageType: StorageType = .privateStorage(), _ recordName: String, completion: @escaping (Result<String, Error>) -> Void) {
                
        let recordID = CKRecord.ID(recordName: recordName)
        storageType.database.delete(withRecordID: recordID) {
            (recordID, error) in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataRemoval))
                return
            }
            
            guard let recordID = recordID else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            completion(.success(recordID.recordName))
        }
    }
    
    /// Removes multiple records from the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordIDs: The UUID's in the database
    ///   - completion: Result object the deleted record ID's or an error
    public static func remove(storageType: StorageType = .privateStorage(), _ recordNames: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        
        let recordIDs = recordNames.map({ CKRecord.ID(recordName: $0) })
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        
        operation.modifyRecordsCompletionBlock = {
            (_, deletedRecordIDs, error) in
            
            if error != nil {
                completion(.failure(StorageError.DDCDataRemoval))
                return
            }
            
            guard let recordIDs = deletedRecordIDs else {
                completion(.failure(StorageError.DDCNullReturn))
                return
            }
            
            completion(.success(recordIDs.map({ $0.recordName })))
        }
        
        storageType.database.add(operation)
    }
    
    /// Removes all records of type T
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - type: The type of the record
    ///   - completion: Result object the deleted record ID's or an error
    public static func removeAll<T: Storable>(storageType: StorageType = .privateStorage(), type: T.Type, completion: @escaping (Result<[String], Error>) -> Void) {
        
        getAll(storageType: storageType) { (result: Result<[T], Error>) in
            
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let values):
                
                guard let recordNames = values.map({ $0.recordName }) as? [String] else {
                    completion(.failure(StorageError.DDCNullRecord))
                    return
                }
                                
                remove(storageType:storageType, recordNames) {
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
    public static func removeAllbyUser<T: Storable>(storageType: StorageType = .privateStorage(), type: T.Type, completion: @escaping (Result<[String], Error>) -> Void) {
        
        fetchRecordsByUser(storageType: storageType) { (result: Result<[T], Error>) in
            
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let values):
                
                guard let recordNames = values.map({ $0.recordName }) as? [String] else {
                    completion(.failure(StorageError.DDCNullRecord))
                    return
                }
                                
                remove(storageType:storageType, recordNames) {
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
    
    /// Remove records using a predicate String
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all deleted record ID's or an error
    ///   - predicate: Predicate string
    public static func remove<T: Storable>(storageType: StorageType = .privateStorage(), type: T.Type, predicate: NSPredicate,  _ completion: @escaping (Result<[String], Error>) -> Void) {
        
        Storage.get(storageType: storageType, predicate: predicate) {
            (result: Result<[T], Error>) in
            
            switch result {
                
            case.failure(let error):
                completion(.failure(error))
                
            case .success(let values):
                
                guard let recordNames = values.map({ $0.recordName }) as? [String] else {
                    completion(.failure(StorageError.DDCNullRecord))
                    return
                }
                                
                remove(storageType:storageType, recordNames) {
                    result in
                    
                    switch result {
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .success(let recordIDs):
                        completion(.success(recordIDs))
                    }
                }
                
                completion(.success(recordNames))
            }
        }
    }
}
