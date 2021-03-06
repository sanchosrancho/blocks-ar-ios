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
    
    
    static func objects(from leftBottom: CLLocationCoordinate2D, to rightTop: CLLocationCoordinate2D) -> Results<Artifact> {
        return Database.realmMain.objects(Artifact.self).filter("latitude >= %@ AND latitude <= %@ AND longitude >= %@ AND longitude <= %@", leftBottom.latitude, rightTop.latitude, leftBottom.longitude, rightTop.longitude)
    }
    
    
    static func getByPosition(position: CLLocationCoordinate2D, withBlocks: Bool) -> Promise<Void> {
        return firstly {
                try Api.run(Api.Artifact.getByPosition(position, withBlocks: withBlocks))
            }.then { response in
                try JSONDecoder().decode(Api.Response<[Api.Artifact.Response]>.self, from: response.data)
            }.then { (json: Api.Response<[Api.Artifact.Response]>) -> [Api.Artifact.Response] in
                guard case .success(let data) = json  else {
                    if case .error(let errorInfo) = json { throw ArtifactsError.responseError(errorInfo) }
                    else { throw ArtifactsError.responseError(nil) }
                }
                return data
            }.then { artifactsResponse in
                try parseAndSave(response: artifactsResponse)
            }.catch { error in
                print("getByPosition error: ", error.localizedDescription)
            }
    }
    
    
    
    static func getByBounds(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, withBlocks: Bool) -> Promise<Void> {
        return firstly {
                try Api.run(Api.Artifact.getByBounds(from: from, to: to, withBlocks: withBlocks))
            }.then { response in
                try JSONDecoder().decode(Api.Response<[Api.Artifact.Response]>.self, from: response.data)
            }.then { (json: Api.Response<[Api.Artifact.Response]>) -> [Api.Artifact.Response] in
                guard case .success(let data) = json  else {
                    if case .error(let errorInfo) = json { throw ArtifactsError.responseError(errorInfo) }
                    else { throw ArtifactsError.responseError(nil) }
                }
                return data
            }.then { artifactsResponse in
                try parseAndSave(response: artifactsResponse)
            }.catch { error in
                print("getByBounds error: ", error.localizedDescription)
            }
    }
    
    static func create(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String, size: Float, onCreateModel: @escaping (ArtifactObjectIdentifier) -> Void) -> Promise<Void> {
        return
            firstly {
                createUploading(location: location, eulerX: eulerX, eulerY: eulerY, eulerZ: eulerZ, distanceToGround: distanceToGround, color: color, size: size)
            }.then { (artifactId) -> ArtifactObjectIdentifier in
                onCreateModel(artifactId)
                return artifactId
            }.then { artifactId in
                try upload(artifactId: artifactId)
            }
    }
    
    static private func upload(artifactId: ArtifactObjectIdentifier) throws -> Promise<Void> {
        let realm = try Database.realmInCurrentContext()
        guard let artifact = find(id: artifactId, realm: realm) else { throw ArtifactsError.artifactNotFound }
        let artifactData = try JSONEncoder().encode(artifact)
//        print(String(data: artifactData, encoding: .utf8) ?? "")
        
        return firstly {
                try Api.run(Api.Block.add(data: artifactData))
            }.then { response in
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
    
    static private func createUploading(location: CLLocation, eulerX: Float, eulerY: Float, eulerZ: Float, distanceToGround: CLLocationDistance, color: String, size: Float) -> Promise<ArtifactObjectIdentifier> {
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
                
                artifact.horizontalAccuracy = Float(location.horizontalAccuracy)
                artifact.verticalAccuracy   = Float(location.verticalAccuracy)
                artifact.groundDistance     = Float(distanceToGround)
                
                artifact.size = size

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
    
    static private func parseAndSave(response: [Api.Artifact.Response]) throws {
        let realm = try Database.realmInCurrentContext()
        Database.save(realm: realm) {
            for artifactResp in response {
                let artifact = Artifact()
                
                artifact.id = artifactResp.id
                artifact.size = artifactResp.size
                artifact.radius = artifactResp.radius
                
                artifact.latitude = artifactResp.latitude
                artifact.longitude = artifactResp.longitude
                artifact.altitude = artifactResp.altitude
                
                artifact.horizontalAccuracy = artifactResp.horizontalAccuracy
                artifact.verticalAccuracy = artifactResp.verticalAccuracy
                artifact.groundDistance = artifactResp.groundDistance
                
                if let blocks = artifactResp.blocks {
                    for blockResp in blocks {
                        let block = Block()
                        block.id = blockResp.id
                        block.hexColor = blockResp.color
                        block.x = blockResp.deltaX
                        block.y = blockResp.deltaY
                        block.z = blockResp.deltaZ
                        block.latitude = blockResp.latitude
                        block.longitude = blockResp.longitude
                        block.altitude = blockResp.altitude
                        artifact.blocks.append(block)
                    }
                }
                
                realm.add(artifact)
            }
        }
    }
}
