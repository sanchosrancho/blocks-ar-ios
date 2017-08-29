//
//  Artifact.swift
//  Modify
//
//  Created by Олег Адамов on 24.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

class Artifact: RealmSwift.Object {
    @objc dynamic var objectId: String = NSUUID().uuidString
    @objc dynamic var lat: CLLocationDegrees = 0
    @objc dynamic var lon: CLLocationDegrees = 0
    @objc dynamic var alt: CLLocationDistance = 0
    @objc dynamic var horizontalAccuracy: CLLocationAccuracy = -2
    @objc dynamic var verticalAccuracy: CLLocationAccuracy = -2
    @objc dynamic var groundDistance: CLLocationDistance = 0
    @objc dynamic var createdAt: NSDate?
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}
