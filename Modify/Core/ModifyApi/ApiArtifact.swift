//
//  ApiArtifact.swift
//  Modify
//
//  Created by Alex Shevlyakov on 15/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Moya
import CoreLocation

extension Api {
    enum Artifact {
        case getByPosition(CLLocationCoordinate2D, withBlocks: Bool)
        case getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, withBlocks: Bool)
    }
}
extension Api.Artifact {
    struct Response: Decodable {
        let id: Int
        let count: Int
        let size: Float
        let radius: Float
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        let altitude: CLLocationDistance
        let horizontalAccuracy: Float
        let verticalAccuracy: Float
        let groundDistance: Float
        
        let blocks: [Api.Block.FullBlockResponse]?
    }
}

extension Api.Artifact: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return Api.baseURL }
    var headers: [String: String]? { return Api.headers }
    var sampleData: Data { return Api.sampleData }
    var method: Moya.Method { return .post }
    var authorizationType: AuthorizationType { return .bearer }
    
    var path: String {
        switch self {
        case .getByPosition: return "/artifact/getByPosition"
        case .getByBounds:   return "/artifact/getByBounds"
        }
    }
    
    var task: Task {
        switch self {
        case .getByPosition(let position, let withBlocks):
            return .requestParameters(parameters: ["position": position.toDictionary,
                                                   "with_blocks": withBlocks], encoding: JSONEncoding.default)
            
        case .getByBounds(let from, let to, let withBlocks):
            return .requestParameters(parameters: [
                "points": [from.toDictionary, to.toDictionary],
                "with_blocks": withBlocks
                ], encoding: JSONEncoding.default)
        }
    }
}

