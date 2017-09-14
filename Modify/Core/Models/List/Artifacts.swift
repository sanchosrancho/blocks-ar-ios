//
//  Artifacts.swift
//  Modify
//
//  Created by Alex Shevlyakov on 08.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift
import PromiseKit
import Moya

struct Artifacts {
    
    static func getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Promise<[Artifact]> {
        return Promise { fulfill, reject in
            
            guard let token = Account.shared.info.token else { throw NSError.cancelledError() }
            let authPlugin = AccessTokenPlugin(tokenClosure: token)
            let api = MoyaProvider<ModifyApi.Artifact>(plugins: [authPlugin, NetworkLoggerPlugin()])
            
            api.request(.getByBounds(from: from, to: to)) { result in
                switch result {
                case let .success(response):
                    do {
                        let data = try JSONDecoder().decode(ModifyApi.Artifact.Response.self, from: response.data)
                        fulfill(data.result)
                    } catch(let error) {
                        reject(error)
                    }
                    
                case let .failure(error): reject(error)
                }
            }
            
        }
    }
}
