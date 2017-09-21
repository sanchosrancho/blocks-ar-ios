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
            throw Application.ConnectionError.loginNeeded
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
    
    static func create(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String) -> Promise<Void> {
        
        return
            firstly {
                createUploading(location: location, eulerX: eulerX, eulerY: eulerY, eulerZ: eulerZ, distanceToGround: distanceToGround, color: color)
            }.then {
                try upload(artifact: $0)
            }
    }
    
    static private func upload(artifact: Artifact) throws -> Promise<Void> {
        guard let token = Account.shared.info.token else {
            throw Application.ConnectionError.loginNeeded
        }
        
        let authPlugin = AccessTokenPlugin(tokenClosure: token)
        let api = MoyaProvider<Api.Block>(plugins: [authPlugin, NetworkLoggerPlugin()])
        
        guard let block = artifact.blocks.first else {
            print("Couldn't find initial block in the artifact");
            throw NSError.cancelledError()
        }
        let blockData = try JSONEncoder().encode(block)
//        let artifactData: Data =
        
        return firstly {
                api.request(target: .add(data: blockData))
            }.then { (response: Moya.Response) -> Api.Block.Response in
                try JSONDecoder().decode(Api.Block.Response.self, from: response.data)
            }.then { (json: Api.Block.Response) -> Void in
                guard let id = json.result.artifact?.id else {
                    print("Couldn't find artifact_id in block's response");
                    throw NSError.cancelledError()
                }
                try! Database.realmMain.write {
                    artifact.id = id
                }
            }
    }
    
    static private func createUploading(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String) -> Promise<Artifact> {
        
        return Promise { fulfill, reject in
            let realm = Database.realmMain
            try! realm.write {
                let artifact = Artifact()
                artifact.eulerX = eulerX
                artifact.eulerY = eulerY
                artifact.eulerZ = eulerZ
                
                artifact.latitude  = location.coordinate.latitude
                artifact.longitude = location.coordinate.longitude
                artifact.altitude  = location.altitude
                
                artifact.horizontalAccuracy = location.horizontalAccuracy
                artifact.verticalAccuracy   = location.verticalAccuracy
                artifact.groundDistance = CLLocationDistance(distanceToGround)
                
                let block = Block()
                block.artifact = artifact
                block.latitude = location.coordinate.latitude
                block.longitude = location.coordinate.longitude
                block.altitude = location.altitude
                
                block.createdAt = Date()
                block.hexColor = color
                
                artifact.blocks.append(block)
                realm.add(artifact)
                
                fulfill(artifact)
            }
        }
    }
}
