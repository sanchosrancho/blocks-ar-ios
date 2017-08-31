//
//  Application.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31/08/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import ARKit
import CoreLocation

struct Application {
    
    enum LocationAccuracyState {
        case poor
        case good
    }
    
    static let sharedInstance = Application()
    private init() {}
    
    var state: Application.LocationAccuracyState = .poor
    
    var cameraTrackingState: ARCamera.TrackingState = .notAvailable
    var locationHorizontalAccuracy: CLLocationAccuracy = -1 { didSet { adjustifyLocationAccuracyState() } }
    var locationVerticalAccuracy:   CLLocationAccuracy = -1 { didSet { adjustifyLocationAccuracyState() } }
    
    private mutating func adjustifyLocationAccuracyState() {
        state = (0...5 ~= locationHorizontalAccuracy && 0...3 ~= locationVerticalAccuracy) ? .good : .poor
    }
    
    
}
