//
//  User.swift
//  Modify
//
//  Created by Alex Shevlyakov on 08/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class User: RealmSwift.Object/*, Codable*/ {
    @objc dynamic var objectId: String = NSUUID().uuidString
    
    @objc dynamic var deviceId:  String?
    @objc dynamic var locale:    String?
    @objc dynamic var pushToken: String?
    @objc dynamic var platform:  String?
    
    let latitude  = RealmOptional<CLLocationDegrees>()
    let longitude = RealmOptional<CLLocationDegrees>()
//    let altitude  = RealmOptional<CLLocationDistance>()
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}

extension User {
    var position: CLLocationCoordinate2D? {
        set(newPosition) {
            latitude.value  = newPosition?.latitude
            longitude.value = newPosition?.longitude
        }
        get {
            guard let lat = latitude.value, let lon = longitude.value else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}


