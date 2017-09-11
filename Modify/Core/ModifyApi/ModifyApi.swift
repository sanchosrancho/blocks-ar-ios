//
//  ModifyApi.swift
//  Modify
//
//  Created by Alex Shevlyakov on 08/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Moya
import CoreLocation

//enum ModifyApi {
//    case userLogin(deviceId: String)
//    case userUpdate
//    case userUpdatePosition
//}

enum ModifyApi {
    enum User {
        case login(deviceId: String)
        case update(locale: String?, pushToken: String?, platform: String?, position: CLLocationCoordinate2D?)
        case updatePosition(CLLocationCoordinate2D)
    }

    enum Artifact {
        case getArtifactsByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
        case addBlock(artifactId: Int)
        case deleteBlock(artifactId: Int)
    }
}

