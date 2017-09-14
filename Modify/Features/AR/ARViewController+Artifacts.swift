//
//  ARViewController+Artifacts.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

extension ARViewController {
    
    func loadAllArtifacts() {
        guard let artifacts = self.artifacts else { return }
        print("Loading all artifacts (\(artifacts.count))...")
        
        let location = sceneLocationView.currentLocation()
        let position = sceneLocationView.currentScenePosition()
        
        for artifact in artifacts {
            guard let artifactNode = ArtifactNode(artifact, currentLocation: location, currentPosition: position) else { continue }
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: artifactNode)
            artifactNodes.append(artifactNode)
        }
    }
    
    
    func deleteArtifacts(indexes: [Int]) {
        print("deleting artefacts at: \(indexes)")
    }
    
    
    func insertArtifacts(indexes: [Int]) {
        guard let artifacts = self.artifacts else { return }
        print("inserting artefacts at: \(indexes)")
        
        let location = sceneLocationView.currentLocation()
        let position = sceneLocationView.currentScenePosition()
        
        for index in indexes {
            guard index < artifacts.count else { continue }
            guard let artifact = ArtifactNode(artifacts[index], currentLocation: location, currentPosition: position) else { continue }
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: artifact)
            artifactNodes.append(artifact)
        }
 
    }
    
    
    func updateArtifacts(indexes: [Int]) {
        print("updating artefacts at: \(indexes)")
        /*
        guard let results = self.results else { return }
        
        let actual = Set( results.map { $0.objectId } )
        print("Location nodes: ", sceneLocationView.locationNodes)
        let onScene = Set( sceneLocationView.locationNodes.map { ($0 as! ArtifactLocationNode).artifactId } )
        
        var shouldBeRemoved = Set(onScene)
        shouldBeRemoved.subtract(actual)
        
        var shouldBeAdded = Set(actual)
        shouldBeAdded.subtract(onScene)
        
        print("\(shouldBeRemoved.count) artifacts should be removed")
        print("\(shouldBeAdded.count) artifacts should be added")
        print("\(results.count) artifacts should be placed on scene")
        
        shouldBeRemoved.forEach {
            guard let node = sceneLocationView.findNode(byId: $0) else { return }
            sceneLocationView.removeLocationNode(locationNode: node)
        }
        
        for artifact in results {
            guard shouldBeAdded.contains(artifact.objectId) else { continue }
            placeArtifact(artifact)
        }
        */
    }
    
}
