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
    
    static func getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) throws -> Promise<[Artifact]> {
        guard let token = Account.shared.info.token else {
            throw NSError.cancelledError()
        }
        
        let authPlugin = AccessTokenPlugin(tokenClosure: token)
        let api = MoyaProvider<Api.Artifact>(plugins: [authPlugin, NetworkLoggerPlugin()])
        
        return firstly {
                api.request(target: .getByBounds(from: from, to: to))
            }.then { (response: Moya.Response) -> Api.Artifact.Response in
                try JSONDecoder().decode(Api.Artifact.Response.self, from: response.data)
            }.then { (json: Api.Artifact.Response) -> [Artifact] in
                json.result
            }
    }
}
