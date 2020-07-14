//
//  Storable.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit
import EVReflection

public protocol Referenciable {
    static var reference: String { get }
}

public typealias CKObject = CKDataObject

public protocol Storable: Referenciable & CKObject {
    
}

