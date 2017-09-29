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
import RealmSwift
import CoreLocation

struct Blocks {
    
    static func find(objectId: BlockObjectIdentifier, realm: Realm) -> Block? {
        return realm.object(ofType: Block.self, forPrimaryKey: objectId)
    }
    
    
    static func find(id: Int, realm: Realm) -> Block? {
        return realm.objects(Block.self).filter("id = %@", id).first
    }
    
    
    static func create(artifactId: ArtifactObjectIdentifier, location: CLLocation, color: UIColor, position: ArtifactPosition) -> Promise<Void> {
        return firstly {
                createUploading(artifactId: artifactId, location: location, color: color, position: position)
            }.then { blockId in
                try upload(blockId: blockId)
            }.catch { error in
                print(error)
            }
    }
    
    static func delete(blockId: Int, latitude: Double, longitude: Double) -> Promise<Void> {
        return firstly {
                try Api.run(Api.Block.delete(blockId: blockId, lat: latitude, lon: longitude))
            }.then { response in
                try JSONDecoder().decode(Api.Response<Api.NoReply>.self, from: response.data)
            }.then { (json: Api.Response<Api.NoReply>) -> Void in
                guard case .success = json else {
                    if case .error(let errorInfo) = json { throw ArtifactsError.responseError(errorInfo) }
                    else { throw ArtifactsError.responseError(nil) }
                }
                
                let realm = try Database.realmInCurrentContext()
                guard let block = find(id: blockId, realm: realm) else { throw ArtifactsError.blockNotFound }
                
                Database.save(realm: realm) {
                    if let artifact = block.artifact, artifact.blocks.count <= 1 {
                        realm.delete(artifact)
                    }
                    realm.delete(block)
                }
            }.catch { error in
                print(error)
            }
    }
    
    
    static private func upload(blockId: BlockObjectIdentifier) throws -> Promise<Void> {
        let realm = try Database.realmInCurrentContext()
        guard let block = find(objectId: blockId, realm: realm) else { throw ArtifactsError.blockNotFound }
        let encodedBlock = try JSONEncoder().encode(block)
        
        return firstly {
                try Api.run(Api.Block.add(data: encodedBlock))
            }.then { response in
                try JSONDecoder().decode(Api.Response<Api.Block.Response>.self, from: response.data)
            }.then { (json: Api.Response<Api.Block.Response>) -> Void in
                guard case .success(let blockInfo) = json else {
                    if case .error(let errorInfo) = json { throw ArtifactsError.responseError(errorInfo) }
                    else { throw ArtifactsError.responseError(nil) }
                }
                
                let realm = try Database.realmInCurrentContext()
                guard let block = find(objectId: blockId, realm: realm) else { throw ArtifactsError.blockNotFound }
                
                Database.save(realm: realm) {
                    block.id = blockInfo.id
                }
            }.catch { error in
                print(error)
            }
    }
    
    static private func createUploading(artifactId: ArtifactObjectIdentifier, location: CLLocation, color: UIColor, position: ArtifactPosition) -> Promise<BlockObjectIdentifier> {
        return Promise { fulfill, reject in
            let realm = try Database.realmInCurrentContext()
            guard let artifact = Artifacts.find(id: artifactId, realm: realm) else { throw ArtifactsError.artifactNotFound }
            Database.save(realm: realm) {
                let block = Block()
                block.artifact = artifact
                
                block.x = position.x
                block.y = position.y
                block.z = position.z
                
                block.latitude = location.coordinate.latitude
                block.longitude = location.coordinate.longitude
                block.altitude = location.altitude
                
                block.createdAt = Date()
                block.color = color
                
                artifact.blocks.append(block)
                
                fulfill(block.objectId)
            }
        }
    }
}
