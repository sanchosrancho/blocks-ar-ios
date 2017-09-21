//
//  Artifact.swift
//  Modify
//
//  Created by Олег Адамов on 24.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

class Artifact: RealmSwift.Object, Codable {
    @objc dynamic var objectId: String = NSUUID().uuidString
    
    @objc dynamic var eulerX: Float = 0
    @objc dynamic var eulerY: Float = 0
    @objc dynamic var eulerZ: Float = 0
    
    @objc dynamic var latitude:  CLLocationDegrees  = 0
    @objc dynamic var longitude: CLLocationDegrees  = 0
    @objc dynamic var altitude:  CLLocationDistance = 0
    
    @objc dynamic var horizontalAccuracy: CLLocationAccuracy = -2
    @objc dynamic var verticalAccuracy:   CLLocationAccuracy = -2
    @objc dynamic var groundDistance:     CLLocationDistance = 0
    
    let blocks = List<Block>()
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}


extension Artifact {
    var locationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
