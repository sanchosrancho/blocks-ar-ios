//
//  Blocks.swift
//  Modify
//
//  Created by Alex Shevlyakov on 14/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import PromiseKit
import Moya

struct Blocks {
    
    static func add(block: Block) throws -> Promise<Void> {
        guard let token = Account.shared.info.token else {
            throw Application.ConnectionError.loginNeeded
        }
        
        let authPlugin = AccessTokenPlugin(tokenClosure: token)
        let api = MoyaProvider<Api.Block>(plugins: [authPlugin, NetworkLoggerPlugin()])
        let encodedBlock = try JSONEncoder().encode(block)

        return
            firstly {
                api.request(target: .add(data: encodedBlock))
            }.then { (response: Moya.Response) -> Api.Block.Response in
                try JSONDecoder().decode(Api.Block.Response.self, from: response.data)
            }.then { (json: Api.Block.Response) -> Void in
                guard json.status == "ok" else {
                    throw NSError.cancelledError()
                }
            }
    }
    
    static func delete(blockId: String) throws -> Promise<Void> {
        guard let token = Account.shared.info.token else {
            throw NSError.cancelledError()
        }
        
        let authPlugin = AccessTokenPlugin(tokenClosure: token)
        let api = MoyaProvider<Api.Block>(plugins: [authPlugin, NetworkLoggerPlugin()])
        
        return firstly {
                api.request(target: .delete(blockId: blockId))
            }.then { response -> Api.Block.Response in
                try JSONDecoder().decode(Api.Block.Response.self, from: response.data)
            }.then { (result: Api.Block.Response) -> Void in
                guard result.status == "ok" else {
                    throw NSError.cancelledError()
                }
            }
    }
}
