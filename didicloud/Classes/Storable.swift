//
//  Storable.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 29/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import CloudKit

public protocol Storable {
    
    static var reference: String { get }
    static var parser: Parser { get }
    
    var recordName: String? { get }
}

public protocol CodableStorable: Storable & Codable {
    
}
