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
    var blockNodes = [BlockNode]()
    
    
    init?(_ artifact: Artifact, currentLocation: CLLocation?, currentPosition: SCNVector3?) {
        guard let location = currentLocation, let position = currentPosition else { return nil }
        guard let mainBlock = artifact.blocks.first else { return nil }
        
        self.artifactId = artifact.objectId
        self.mainBlockNode = BlockNode(block: mainBlock, position: SCNVector3Zero, artifactId: artifact.objectId)
        
        let altitude = location.altitude - Double(position.y) + mainBlock.groundDistance
        let coord = CLLocationCoordinate2D(latitude: mainBlock.latitude, longitude: mainBlock.longitude)
        
        super.init(location: CLLocation(coordinate: coord, altitude: altitude))
        self.eulerAngles = SCNVector3(artifact.eulerX, artifact.eulerY, artifact.eulerZ)
        
        self.addChildNode(mainBlockNode)
    }
    
    
    func update(with artifact: Artifact) {
        // test
        guard artifact.objectId == self.artifactId else { return }
        guard artifact.blocks.count > 1 else { return }
        
        for blockNode in blockNodes { blockNode.removeFromParentNode() }
        blockNodes.removeAll()
        for i in 1..<artifact.blocks.count {
            let block = artifact.blocks[i]
            let translation = block.location.translation(toLocation: self.location)
            let pos = SCNVector3(translation.longitudeTranslation, translation.altitudeTranslation, translation.latitudeTranslation)
            let blockNode = BlockNode(block: block, position: pos, artifactId: artifactId)
            self.addChildNode(blockNode)
            blockNodes.append(blockNode)
        }
    }
    
    
    //MARK: - Private
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class BlockNode: CubeNode {
    let artifactId: String
    var lat: Double
    var lon: Double
    var alt: Double
    
    
    init(block: Block, position: SCNVector3, artifactId: String) {
        self.lat = block.latitude
        self.lon = block.longitude
        self.alt = block.altitude
        
        self.artifactId = artifactId
        
        super.init(position: position, color: block.color)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
