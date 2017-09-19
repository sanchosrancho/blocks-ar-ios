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
        
        for index in indexes {
            guard index < artifactNodes.count else { continue }
            let artifactNode = artifactNodes[index]
            sceneLocationView.removeLocationNode(locationNode: artifactNode)
            artifactNodes.remove(object: artifactNode)
        }
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
            if index < artifactNodes.count {
                artifactNodes.insert(artifact, at: index)
            } else {
                artifactNodes.append(artifact)
            }
        }
    }
    
    
    func updateArtifacts(indexes: [Int]) {
        guard let artifacts = self.artifacts else { return }
        print("updating artefacts at: \(indexes)")
        
        for index in indexes {
            guard index < artifacts.count, index < artifactNodes.count else { continue }
            let artifact = artifacts[index]
            artifactNodes[index].updateBlocks(with: artifact)
        }
    }
    
}


extension ARViewController {
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let obj = self.artifacts?.first else { return }
            print("remove first object!")
            let realm = self.realm
            try! realm?.write {
                realm?.delete(obj)
            }
        }
    }
}
