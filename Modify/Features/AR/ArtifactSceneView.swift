//
//  ArtifactSceneView.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//
import Foundation

class ArtifactSceneView: SceneLocationView {
    
    var bestLocationUntilDate: Date?
    
    override func bestLocationEstimate() -> SceneLocationEstimate? {
        guard let untilDate = bestLocationUntilDate else {
            return super.bestLocationEstimate()
        }
        
        let sortedLocationEstimates = sceneLocationEstimates.sorted(by: {
            if $0.location.timestamp > untilDate, $1.location.timestamp <= untilDate {
                return false
            }
            
            if $0.location.horizontalAccuracy == $1.location.horizontalAccuracy {
                return $0.location.timestamp > $1.location.timestamp
            }

            return $0.location.horizontalAccuracy < $1.location.horizontalAccuracy
        })

        return sortedLocationEstimates.first
    }
    
    public func findNode(by objectId: String) -> ArtifactNode? {
        for node in self.locationNodes {
            guard let artifactNode = node as? ArtifactNode else { continue }
            if artifactNode.artifactId == objectId {
                return artifactNode
            }
        }
        return nil
    }
    
}
