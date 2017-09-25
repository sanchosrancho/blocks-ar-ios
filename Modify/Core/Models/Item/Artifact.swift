//
//  Artifact.swift
//  Modify
//
//  Created by Олег Адамов on 24.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

class Artifact: RealmSwift.Object, Decodable {
    @objc dynamic var objectId: String = NSUUID().uuidString
    
    @objc dynamic var id: Int = 0
    
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

//extension Artifact {
//    func export() -> [String: Any] {
//        return [:]
//    }
//}

extension Artifact: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case eulerX
        case latitude
        case longitude
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case groundDistance
        case color
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if id != 0 {
            try container.encode(id, forKey: .id)
        }
        
        if let color = blocks.first?.hexColor {
            try container.encode(color, forKey: .color)
        }
        
        try container.encode(eulerX, forKey: .eulerX)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(groundDistance, forKey: .groundDistance)
    }
}
