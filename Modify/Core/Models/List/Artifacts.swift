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

enum ArtifactsError: Error {
    case artifactNotFound
    case blockNotFound
}

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
    
    static func find(id: ArtifactObjectIdentifier, realm: Realm) -> Artifact? {
        return realm.object(ofType: Artifact.self, forPrimaryKey: id)
    }
    
    static func create(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String) -> Promise<Void> {
        return
            firstly {
                createUploading(location: location, eulerX: eulerX, eulerY: eulerY, eulerZ: eulerZ, distanceToGround: distanceToGround, color: color)
            }.then { artifactId in
                try upload(artifactId: artifactId)
            }
    }
    
    static private func upload(artifactId: ArtifactObjectIdentifier) throws -> Promise<Void> {
        let realm = try DB.realmInCurrentContext()
        guard let artifact = find(id: artifactId, realm: realm) else {
            throw ArtifactsError.artifactNotFound
        }
        let artifactData = try JSONEncoder().encode(artifact)
        
        return firstly {
                try Api.run(Api.Block.add(data: artifactData))
            }.then { (response: Moya.Response) -> Void in
                let json = try JSONDecoder().decode(Api.Block.Response.Add.self, from: response.data)
                
                let apiBlockId = json.result.id
                let apiArtifactId = json.result.artifact
                
                let realm = try DB.realmInCurrentContext()
                guard let artifact = find(id: artifactId, realm: realm) else {
                    throw ArtifactsError.artifactNotFound
                }
                guard let block = artifact.blocks.first else {
                    throw ArtifactsError.blockNotFound
                }
                DB.save(realm: realm) {
                    artifact.id = apiArtifactId
                    block.id = apiBlockId
                }
            }
    }
    
    static private func createUploading(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String) -> Promise<ArtifactObjectIdentifier> {
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
                
                fulfill(artifact.objectId)
            }
        }
    }
}
