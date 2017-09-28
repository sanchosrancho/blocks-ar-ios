//
//  ArtifactNode.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import CoreLocation
import SceneKit

class ArtifactNode: LocationNode {
    
    let artifactId: String
    
    
    init?(_ artifact: Artifact, currentLocation: CLLocation?, currentPosition: SCNVector3?) {
        guard let location = currentLocation, let position = currentPosition else { return nil }

        self.artifactId = artifact.objectId
        
        let altitude = location.altitude - Double(position.y) + Double(artifact.groundDistance)
        let coord = artifact.locationCoordinate2D
        
        super.init(location: CLLocation(coordinate: coord, altitude: Double(altitude)))
        self.eulerAngles = SCNVector3(artifact.eulerX, artifact.eulerY, artifact.eulerZ)
        
        updateBlocks(with: artifact)
    }
    
    
    func updateBlocks(with artifact: Artifact) {
        guard artifact.objectId == self.artifactId else { return }
        guard let nodes = self.childNodes as? [BlockNode] else { return }
        
        var presentedBlockIds = [String]()
        
        // delete
        var nodesToRemove = [BlockNode]()
        let blockIds = artifact.blocks.map { $0.objectId }
        for node in nodes {
            if !blockIds.contains(node.blockId) {
                nodesToRemove.append(node)
            } else {
                presentedBlockIds.append(node.blockId)
            }
        }
        nodesToRemove.forEach { $0.removeFromParentNode() }
        
        // insert
        for block in artifact.blocks {
            guard !presentedBlockIds.contains(block.objectId) else { continue }
            let blockNode = BlockNode(block: block, artifactId: artifact.objectId)
            self.addChildNode(blockNode)
        }
    }
    
    
    //MARK: - Private
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
