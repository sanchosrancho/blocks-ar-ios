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

public final class Application {
    
    enum LocationAccuracyState {
        case poor
        case good
    }
    
    private static let _shared = Application()
    public static var shared: Application {
        return _shared
    }
    
    private init() {}
    
    var state: Application.LocationAccuracyState = .poor {
        willSet(newState) {
            guard newState != state else { return }
            switch newState {
            case .poor: NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ApplicationLocationAccuracyDidChange"), object: nil, userInfo: ["current": Application.LocationAccuracyState.poor]))
            case .good: NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ApplicationLocationAccuracyDidChange"), object: nil, userInfo: ["current": Application.LocationAccuracyState.good]))
            }
        }
    }
    
    var cameraTrackingState: ARCamera.TrackingState = .notAvailable
    var locationHorizontalAccuracy: CLLocationAccuracy = -1 { didSet { adjustifyLocationAccuracyState() } }
    var locationVerticalAccuracy:   CLLocationAccuracy = -1 { didSet { adjustifyLocationAccuracyState() } }
    
    private func adjustifyLocationAccuracyState() {
        state = (0...10 ~= locationHorizontalAccuracy && 0...5 ~= locationVerticalAccuracy) ? .good : .poor
    }
    
    
}
