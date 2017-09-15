//
//  Api.swift
//  Modify
//
//  Created by Alex Shevlyakov on 08/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Moya
import CoreLocation

struct Api {
    enum User {
        case login(deviceId: String)
        case update(locale: String?, pushToken: String?, platform: String?, position: CLLocationCoordinate2D?)
        case updatePosition(CLLocationCoordinate2D)
    }

    enum Artifact {
        case getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
    }

    enum Block {
        case add(data: Data)
        case delete(blockId: String)
    }
}

extension Api {
    static let baseURL = { URL(string: "http://212.224.112.252")! }()
    static let headers = ["Content-type": "application/json"]
    static let sampleData = { "{\"status\": \"ok\", \"result\": {}".utf8Encoded }()
}


// MARK: - Helpers
private extension CLLocationCoordinate2D {
    var toDictionary: [String:CLLocationDegrees] {
        return ["latitude": self.latitude, "longitude": self.longitude]
    }
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
