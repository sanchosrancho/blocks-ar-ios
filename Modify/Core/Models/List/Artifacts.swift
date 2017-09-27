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
    case responseError(Api.ResponseError?)
    
    var localizedDescription: String {
        switch self {
        case .artifactNotFound: return "Artifact not found"
        case .blockNotFound:    return "Block not found"
        case .responseError(let errorInfo): return "Response error: " + errorInfo.debugDescription
        }
    }
}

struct Artifacts {
    
    static func find(id: ArtifactObjectIdentifier, realm: Realm) -> Artifact? {
        return realm.object(ofType: Artifact.self, forPrimaryKey: id)
    }
    
    static func getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) throws -> Promise<[Artifact]> {
        return firstly {
                try Api.run(Api.Artifact.getByBounds(from: from, to: to))
            }.then { (response: Moya.Response) -> Api.Response<[Artifact]> in
                try JSONDecoder().decode(Api.Response<[Artifact]>.self, from: response.data)
            }.then { (json: Api.Response<[Artifact]>) -> [Artifact] in
                guard case .success(let data) = json  else {
                    if case .error(let errorInfo) = json { throw ArtifactsError.responseError(errorInfo) }
                    else { throw ArtifactsError.responseError(nil) }
                }
                return data
            }.catch { error in
                print("getByBounds error: ", error.localizedDescription)
            }
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
        let realm = try Database.realmInCurrentContext()
        guard let artifact = find(id: artifactId, realm: realm) else { throw ArtifactsError.artifactNotFound }
        let artifactData = try JSONEncoder().encode(artifact)
        print(String(data: artifactData, encoding: .utf8))
        
        return firstly {
                try Api.run(Api.Block.add(data: artifactData))
            }.then { (response: Moya.Response) -> Api.Response<Api.Block.Response> in
                try JSONDecoder().decode(Api.Response<Api.Block.Response>.self, from: response.data)
            }.then { (json: Api.Response<Api.Block.Response>) -> Void in
                guard case .success(let blockInfo) = json else {
                    if case .error(let errorInfo) = json { throw ArtifactsError.responseError(errorInfo) }
                    else { throw ArtifactsError.responseError(nil) }
                }
                
                let realm = try Database.realmInCurrentContext()
                guard let artifact = find(id: artifactId, realm: realm) else { throw ArtifactsError.artifactNotFound }
                guard let block = artifact.blocks.first else { throw ArtifactsError.blockNotFound }
                
                Database.save(realm: realm) {
                    artifact.id = blockInfo.artifact
                    block.id = blockInfo.id
                }
            }.catch { error in
                print(error)
            }
    }
    
    static private func createUploading(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String) -> Promise<ArtifactObjectIdentifier> {
        return Promise { fulfill, reject in
            let realm = try Database.realmInCurrentContext()
            Database.save(realm: realm) {
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
