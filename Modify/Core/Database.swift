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
        return try! Realm(fileURL: URL(fileURLWithPath: Database.path))
    }()
    
    static public func doAndSave(realm: Realm, operation: () -> Void) {
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
    
    static func doInCurrentThread(_ operation: (Realm) -> Void) {
        do {
            let realm = try Realm(fileURL: URL(fileURLWithPath: Database.path))
            operation(realm)
        } catch let error {
            print(error)
        }
    }
    
    static func doInBackground(operation: @escaping (Realm) -> Void) {
        self.queue.async {
            self.doInCurrentThread(operation)
        }
    }
}
