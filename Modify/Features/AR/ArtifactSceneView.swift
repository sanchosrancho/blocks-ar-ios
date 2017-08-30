//
//  ArtifactSceneView.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

class ArtifactSceneView: SceneLocationView {
    
    public func findNode(byId id: String) -> ArtifactNode? {
        for node in self.locationNodes {
            guard let artifactNode = node as? ArtifactNode else { continue }
            if artifactNode.artifactId == id {
                return artifactNode
            }
        }
        return nil
    }
}
