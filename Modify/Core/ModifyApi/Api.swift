//
//  Api.swift
//  Modify
//
//  Created by Alex Shevlyakov on 08/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import CoreLocation
import Moya
import PromiseKit

class Api {
//    static let socketURL = { URL(string: "ws://192.168.1.130:1323/sockets/")! }()
//    static let baseURL = { URL(string: "http://192.168.1.130:1323")! }()
    static let socketURL = { URL(string: "ws://212.224.112.252/sockets/")! }()
    static let baseURL = { URL(string: "http://212.224.112.252")! }()
    static let headers = ["Content-type": "application/json"]
    static let sampleData = { "{\"status\": \"ok\", \"result\": {}".utf8Encoded }()
    
    private static let _shared = Api()
    public static var shared: Api { return _shared }
    
    public var token: String?
}

extension Api {
    static func run<T>(_ method: T) throws -> Promise<Moya.Response> where T: TargetType & AccessTokenAuthorizable {
        if method.authorizationType == .none {
            return MoyaProvider<T>(plugins: [NetworkLoggerPlugin()]).request(target: method)
        }
        
        guard let token = Api.shared.token else {
            throw Application.ConnectionError.loginNeeded
        }
        let authPlugin = AccessTokenPlugin(tokenClosure: token)
        let api = MoyaProvider<T>(plugins: [authPlugin, NetworkLoggerPlugin()])
        return api.request(target: method)
    }
}


// MARK: - Helpers

internal extension CLLocationCoordinate2D {
    var toDictionary: [String:CLLocationDegrees] {
        return ["latitude": self.latitude, "longitude": self.longitude]
    }
}

internal extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
