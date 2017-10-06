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
    
    func reload() {
        guard let artifacts = self.artifacts else { return }
        print("Loading all artifacts (count: \(artifacts.count))...")
        
        let location = sceneLocationView.currentLocation()
        let position = sceneLocationView.currentScenePosition()
        
        for artifact in artifacts {
            guard let artifactNode = ArtifactNode(artifact, currentLocation: location, currentPosition: position) else { continue }
            print("Placing artifact with location: (\(artifact.latitude), \(artifact.longitude), \(artifact.altitude))")
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: artifactNode)
            artifactNodes.append(artifactNode)
        }
    }
    
    
    func delete(indexes: [Int]) {
        print("deleting artefacts at: \(indexes)")
        
        var currentArtifactNodeId: BlockObjectIdentifier?
        if case .editing(let artifactNode) = self.placeState {
            currentArtifactNodeId = artifactNode.artifactId
        }
        
        for index in indexes {
            guard index < artifactNodes.count else { continue }
            let artifactNode = artifactNodes[index]
            sceneLocationView.removeLocationNode(locationNode: artifactNode)
            artifactNodes.remove(object: artifactNode)
            
            if artifactNode.artifactId == currentArtifactNodeId {
                self.placeState = .preview
            }
        }
    }
    
    
    func insert(indexes: [Int]) {
        guard let artifacts = self.artifacts else { return }
        print("inserting artefacts at: \(indexes)")
        
        let location = sceneLocationView.currentLocation()
        let position = sceneLocationView.currentScenePosition()
        
        for index in indexes {
            guard index < artifacts.count else { continue }
            let artifact = artifacts[index]
            
            guard let artifactNode = ArtifactNode(artifact, currentLocation: location, currentPosition: position) else { continue }
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: artifactNode)
            
            if index < self.artifactNodes.count {
                artifactNodes.insert(artifactNode, at: index)
            } else {
                artifactNodes.append(artifactNode)
            }
            
            if self.creatingArtifactObjectId == artifact.objectId, case .preview = self.placeState {
                self.placeState = .editing(artifactNode)
                self.creatingArtifactObjectId = nil
            }
        }
    }
    
    
    func update(indexes: [Int]) {
        guard let artifacts = self.artifacts else { return }
        print("updating artefacts at: \(indexes)")
        
        for index in indexes {
            guard index < artifacts.count, index < artifactNodes.count else { continue }
            let artifact = artifacts[index]
            artifactNodes[index].updateBlocks(with: artifact)
        }
    }
    
}
