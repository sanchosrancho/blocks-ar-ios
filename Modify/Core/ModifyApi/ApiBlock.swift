//
//  ApiBlock.swift
//  Modify
//
//  Created by Alex Shevlyakov on 15/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Moya

extension Api {
    enum Block {
        case add(data: Data)
        case delete(blockId: String)
    }
}

extension Api.Block {
    struct Response:Decodable {
        let status: String
        let result: Block
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
        case .add(let data):       return .requestParameters(parameters: ["block": data],       encoding: JSONEncoding.default)
        case .delete(let blockId): return .requestParameters(parameters: ["block_id": blockId], encoding: JSONEncoding.default)
        }
    }
}
