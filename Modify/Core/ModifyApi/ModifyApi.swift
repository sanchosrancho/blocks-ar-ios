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

struct ModifyApi {
    enum User {
        case login(deviceId: String)
        case update(locale: String?, pushToken: String?, platform: String?, position: CLLocationCoordinate2D?)
        case updatePosition(CLLocationCoordinate2D)
    }

    enum Artifact {
        case getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
    }
    
    enum Block {
        case add(artifactId: Int)
        case delete(artifactId: Int)
    }
    
    static var BaseURL: URL { return URL(string: "http://192.168.1.130")! }
    static var Headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

extension ModifyApi.User: TargetType {
    var baseURL: URL { return ModifyApi.BaseURL }
    var headers: [String: String]? { return ModifyApi.Headers }
    
    var path: String {
        switch self {
        case .login:  return "/user/login"
        case .update: return "/user/update"
        case .updatePosition: return "/user/updatePosition"
        }
    }
    var method: Moya.Method { return .post }
    var task: Task {
        switch self {
        case .login(let deviceId):
            return .requestParameters(parameters: ["device_id": deviceId], encoding: JSONEncoding.default)
            
        case .update(let locale, let pushToken, let platform, let position):
            var params = [String: Any]()
            if let loc    = locale    { params["locale"]     = loc }
            if let push   = pushToken { params["push_token"] = push }
            if let pltfrm = platform  { params["platform"]   = pltfrm }
            if let pos    = position  { params["position"]   = ["latitude": pos.latitude, "longitude": pos.longitude] }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .updatePosition(let position):
            return .requestParameters(parameters: ["latitude": position.latitude, "longitude": position.longitude], encoding: JSONEncoding.default)
        }
    }
    var sampleData: Data {
        let successResponse = "{\"status\": \"ok\", \"result\": { \"token\": \"sample_token\"}".utf8Encoded
        return successResponse
    }
}

func test() {
    let provider = MoyaProvider<ModifyApi.User>()
    provider.request(.login(deviceId: "")) {result in
        
    }
    
    
    let pr2 = MoyaProvider<MultiTarget>()
    pr2.request(MultiTarget(ModifyApi.User.login(deviceId: ""))) { result in
        
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
