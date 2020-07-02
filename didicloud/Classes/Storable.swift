//
//  Storable.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit

public protocol Storable {
    static var reference: String { get }
    var record: CKRecord? { get }
    var id: CKRecord.ID? { get }
    init(_ record: CKRecord)
}
