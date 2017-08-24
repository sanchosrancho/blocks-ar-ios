//
//  Artifact.swift
//  Modify
//
//  Created by Олег Адамов on 24.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import RealmSwift
import CoreLocation

@objc class Artifact: Object {
    @objc dynamic var lat: CLLocationDegrees = 0
    @objc dynamic var lon: CLLocationDegrees = 0
    @objc dynamic var alt: CLLocationDistance = 0
}
