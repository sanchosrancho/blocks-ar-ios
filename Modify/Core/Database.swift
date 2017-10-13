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
    static private let queue = DispatchQueue(label: "com.modify.database.queue")
    
    static let realmMain: Realm = {
        return try! realmInCurrentContext()
    }()
    
    static func realmInCurrentContext() throws -> Realm {
        return try Realm(fileURL: URL(fileURLWithPath: Database.path))
    }
    
    static func run(_ operation: (Realm) -> Void) {
        do {
            operation(try realmInCurrentContext())
        } catch let error {
            print(error)
        }
    }
    
    static func runAsync(_ operation: @escaping (Realm) -> Void) {
        queue.async { run(operation) }
    }
    
    static func save(realm: Realm, operation: () -> Void) {
        guard realm.isInWriteTransaction != true else {
            operation()
            return
        }
        
        do {
            try realm.write { operation() }
        } catch (let error) {
            print(error)
        }
    }
    
    
    static func clean() {
        let realm = Database.realmMain
        try? realm.write {
            realm.deleteAll()
        }
    }
}
