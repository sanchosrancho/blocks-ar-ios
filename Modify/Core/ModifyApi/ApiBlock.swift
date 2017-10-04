//
//  ApiBlock.swift
//  Modify
//
//  Created by Alex Shevlyakov on 15/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Moya
import CoreLocation

extension Api {
    enum Block {
        case add(data: Data)
        case delete(blockId: String)
    }
}

extension Api.Block {
    struct Response: Decodable {
        let artifact: Int
        let id: String
    }
    
    struct FullBlockResponse: Decodable {
        let id: String
        let artifact: Int
        let color: String
        let deltaX: Int32
        let deltaY: Int32
        let deltaZ: Int32
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        let altitude: CLLocationDistance
        let horizontalAccuracy: Float
        let verticalAccuracy: Float
        let groundDistance: Float
    }
}

extension Api.Block: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return Api.baseURL }
    var headers: [String: String]? { return Api.headers }
    var sampleData: Data { return Api.sampleData }
    var method: Moya.Method { return .post }
    var authorizationType: AuthorizationType { return .bearer }
    
    var path: String {
        switch self {
        case .add:    return "/block/add"
        case .delete: return "/block/delete"
        }
    }
    
    var task: Task {
        switch self {
        case .add(let data):
            return .requestData(data) //.requestParameters(parameters: ["block": String.init(data: data, encoding: .utf8)!],       encoding: JSONEncoding.default)
        case .delete(let blockId):
            return .requestParameters(parameters: ["block_id": blockId], encoding: JSONEncoding.default)
        }
    }
}
