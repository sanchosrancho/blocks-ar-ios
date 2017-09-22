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
    struct Response {
        struct Delete: Decodable {
            let status: String
        }
        
        struct Add:Decodable {
            let status: String
            let result: Block
            
            struct Block: Decodable {
                let artifact: Int
                let id: Int
            }
        }
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
        case .add(let data):       return .requestData(data) //.requestParameters(parameters: ["block": String.init(data: data, encoding: .utf8)!],       encoding: JSONEncoding.default)
        case .delete(let blockId): return .requestParameters(parameters: ["block_id": blockId], encoding: JSONEncoding.default)
        }
    }
}