//
//  Block.swift
//  Modify
//
//  Created by Alex Shevlyakov on 07.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

class Block: RealmSwift.Object/*, Codable*/ {
    @objc dynamic var objectId: String = NSUUID().uuidString
    @objc dynamic var author: User?
    @objc dynamic var artifact: Artifact?
    
    @objc dynamic var latitude:  CLLocationDegrees  = 0
    @objc dynamic var longitude: CLLocationDegrees  = 0
    @objc dynamic var altitude:  CLLocationDistance = 0
    
    @objc dynamic var horizontalAccuracy: CLLocationAccuracy = -2
    @objc dynamic var verticalAccuracy:   CLLocationAccuracy = -2
    @objc dynamic var groundDistance:     CLLocationDistance = 0
    
//    @objc dynamic var color: UIColor = UIColor.clear
    @objc dynamic var createdAt: Date?
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}

