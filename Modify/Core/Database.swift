//
//  Database.swift
//  Modify
//
//  Created by Alex Shevlyakov on 22.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import RealmSwift

struct Database {
    
    static private let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    static private let path = documents + "/modify.realm"
    
    static let realmMain: Realm = {
        return try! Realm(fileURL: URL(fileURLWithPath: Database.path))
    }()
}
