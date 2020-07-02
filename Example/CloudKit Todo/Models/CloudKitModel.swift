//
//  CloudKitModel.swift
//  CloudKit Todo
//
//  Created by Rodrigo Giglio on 28/06/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import Foundation
import CloudKit


protocol CloudKitModel {

    var id: CKRecord.ID { get }

    
    func readAll()
    func read(_ id: CKRecord.ID)
    func create()
    func update()
    func delete()
}
