//
//  ApiUser.swift
//  Modify
//
//  Created by Alex Shevlyakov on 15/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Moya

extension Api.User {
    struct Response: Decodable {
        let status: String
        let result: LoginResult
    }
    struct LoginResult: Decodable {
        let token: String
    }
}

extension Api.User: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return Api.baseURL }
    var headers: [String: String]? { return Api.headers }
    var sampleData: Data { return Api.sampleData }
    var method: Moya.Method { return .post }
    
    var authorizationType: AuthorizationType {
        if case .login = self { return .none }
        return .bearer
    }
    
    var path: String {
        switch self {
        case .login:  return "/user/login"
        case .update: return "/user/update"
        case .updatePosition: return "/user/updatePosition"
        }
    }
    
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
}
