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
    var mainBlockNode: BlockNode!
    
    init?(_ artifact: Artifact, currentLocation: CLLocation?, currentPosition: SCNVector3?) {
        guard let location = currentLocation, let position = currentPosition else { return nil }
        guard let mainBlock = artifact.blocks.first else { return nil }
        
        let mainBlockNode = BlockNode(block: mainBlock, position: SCNVector3Zero)
        
        self.artifactId = artifact.objectId
        self.mainBlockNode = mainBlockNode
        
        let altitude = location.altitude - Double(position.y) + mainBlock.groundDistance
        let coord = CLLocationCoordinate2D(latitude: mainBlock.latitude, longitude: mainBlock.longitude)
        
        super.init(location: CLLocation(coordinate: coord, altitude: altitude))
        self.eulerAngles = SCNVector3(artifact.eulerX, artifact.eulerY, artifact.eulerZ)
        
        self.addChildNode(mainBlockNode)
    }
    
    
    //MARK: - Private
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class BlockNode: CubeNode {
    
    init(block: Block, position: SCNVector3) {
        super.init(position: position, color: block.color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
