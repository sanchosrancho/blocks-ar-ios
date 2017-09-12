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
    @objc dynamic var eulerX: Float = 0
    @objc dynamic var eulerY: Float = 0
    @objc dynamic var eulerZ: Float = 0
    let blocks = List<Block>()
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}
