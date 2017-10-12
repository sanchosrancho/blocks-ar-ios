//
//  MapCircle.swift
//  Modify
//
//  Created by Олег Адамов on 12.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import MapKit

class MapCircle: MKCircle {

    var objectId: ArtifactObjectIdentifier = ""
    
    convenience init(center: CLLocationCoordinate2D, radius: Float, objectId: ArtifactObjectIdentifier) {
        self.init(center: center, radius: CLLocationDistance(radius))
        self.objectId = objectId
    }
}
