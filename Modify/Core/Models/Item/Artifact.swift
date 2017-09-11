//
//  Artifact.swift
//  Modify
//
//  Created by Олег Адамов on 24.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

class Artifact: RealmSwift.Object/*, Codable*/ {
    @objc dynamic var objectId: String = NSUUID().uuidString
    @objc dynamic var genesisBlock: Block?
    
    let blocks = List<Block>()
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}
