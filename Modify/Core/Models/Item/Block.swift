//
//  Block.swift
//  Modify
//
//  Created by Alex Shevlyakov on 07.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

typealias BlockObjectIdentifier = String

class Block: RealmSwift.Object {
    @objc dynamic var objectId: BlockObjectIdentifier = NSUUID().uuidString
    
    @objc dynamic var id: String = ""
    @objc dynamic var author: User?
    @objc dynamic var artifact: Artifact?
    
    @objc dynamic var latitude:  CLLocationDegrees  = 0
    @objc dynamic var longitude: CLLocationDegrees  = 0
    @objc dynamic var altitude:  CLLocationDistance = 0

    @objc dynamic var x: Int32 = 0
    @objc dynamic var y: Int32 = 0
    @objc dynamic var z: Int32 = 0
    
    @objc dynamic var hexColor: String?
    @objc dynamic var createdAt: Date?
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}


extension Block {
    var color: UIColor {
        get { return UIColor.fromHex(hexColor) }
        set(color) { hexColor = color.hexString() }
    }
}

extension Block: Encodable {
    
    enum MainCodingKeys: String, CodingKey {
        case block
    }
    
    enum CodingKeys: String, CodingKey {
        case id, artifact, latitude, longitude, altitude, x, y, z, color, size
    }
    
    public func encode(to encoder: Encoder) throws {
        var mainContainer = encoder.container(keyedBy: MainCodingKeys.self)
        var container = mainContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .block)
//        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if !id.isEmpty {
            try container.encode(id, forKey: .id)
        }
        try container.encodeIfPresent(self.artifact?.id, forKey: .artifact)
        
        try container.encode(latitude,  forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(altitude,  forKey: .altitude)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
        try container.encode(1, forKey: .size)
        try container.encodeIfPresent(hexColor, forKey: .color)
    }
}
