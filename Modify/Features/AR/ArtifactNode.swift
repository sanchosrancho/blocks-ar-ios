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
    
    let artifactId: ArtifactObjectIdentifier
    
    
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
        
        var presentedBlockIds = [BlockObjectIdentifier]()
        
        // delete or update
        var nodesToRemove = [BlockNode]()
        for node in nodes {
            var containsId: Int?
            for block in artifact.blocks {
                if block.objectId == node.objectId {
                    containsId = block.id
                    break
                }
            }
            if let newId = containsId  {
                node.id = newId
                presentedBlockIds.append(node.objectId)
            } else {
                nodesToRemove.append(node)
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
