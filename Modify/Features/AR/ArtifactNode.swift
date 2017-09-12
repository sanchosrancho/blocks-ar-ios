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
    
    let artifactId: Int
    
    init(artifact: Artifact) {
        self.artifactId = artifact.objectId
        
        super.init(location: location)
        
        test()
    }
    
    
    //MARK: - Private
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func test() {
        let matertial = SCNMaterial()
        matertial.diffuse.contents = UIColor.red
        let geometry = SCNSphere(radius: 0.1)
        geometry.materials = [matertial]
        let node = SCNNode(geometry: geometry)
        self.addChildNode(node)
    }
}

class ObjectNode: SCNNode {
    
}

/*
class ArtifactLocationNode: LocationNode {
    
    let artifactId: String
    let object: ArtifactNode
    
    
    public init?(artifact: Artifact, location: CLLocation?) {
        guard let object = ArtifactNode(name: artifact.modelName) else { return nil }
        object.node.eulerAngles = SCNVector3(artifact.eulerX, artifact.eulerY, artifact.eulerZ)
        self.artifactId = artifact.objectId
        self.object = object
        
        super.init(location: location)

        self.addChildNode(object.node)
    }
    
    
    //MARK: - Private
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


enum ArtifactModelType: String {
    case rainbow
    case lips
    case ship
}


extension ArtifactModelType {
    
    var scale: SCNVector3 {
        var value: Float = 1
        switch self {
            case .lips:    value = 0.015
            case .rainbow: value = 0.8
            case .ship:    break
        }
        return SCNVector3(value,value,value)
    }
}
*/
