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
    
    func add(block: Block) -> Promise<Void> {
        return Promise { fulfill, reject in
            
            guard let token = Account.shared.info.token else { throw NSError.cancelledError() }
            let authPlugin = AccessTokenPlugin(tokenClosure: token)
            let api = MoyaProvider<ModifyApi.Block>(plugins: [authPlugin, NetworkLoggerPlugin()])
            
            do {
                let encodedBlock = try JSONEncoder().encode(block)
//                let encoded = String(data: data, encoding: .utf8)!
                
                api.request(.add(data: encodedBlock)) { result in
                    switch result {
                    case let .success(response):
                        do {
                            let result = try JSONDecoder().decode(ModifyApi.Block.Response.self, from: response.data)
                            guard result.status == "ok" else { reject(NSError.cancelledError()); return }
                            fulfill(())
                        } catch(let error) {
                            reject(error)
                        }
                        
                    case let .failure(error):
                        reject(error)
                    }
                }
                
            } catch (let error) {
                reject(error)
            }
            
        }
    }
    
    func delete(blockId: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            
            guard let token = Account.shared.info.token else { throw NSError.cancelledError() }
            let authPlugin = AccessTokenPlugin(tokenClosure: token)
            let api = MoyaProvider<ModifyApi.Block>(plugins: [authPlugin, NetworkLoggerPlugin()])
            api.request(.delete(blockId: blockId)) { result in
                
                switch result {
                case let .success(response):
                    do {
                        let result = try JSONDecoder().decode(ModifyApi.Block.Response.self, from: response.data)
                        guard result.status == "ok" else { reject(NSError.cancelledError()); return }
                        fulfill(())
                    } catch(let error) {
                        reject(error)
                    }
                    
                case let .failure(error):
                    reject(error)
                }
                
            }
            
        }
    }
    
}
