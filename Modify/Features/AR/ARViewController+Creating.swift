//
//  ARViewController+Creating.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

extension ARViewController {
    
    enum PlaceState {
        case preview
        case placing(CubeNode)
        case editing
    }
    
    
    func addInitialCubeToCamera(with color: UIColor) {
        let cubeNode = CubeNode(position: SCNVector3(0, 0, zDistance), color: color)
        sceneLocationView.pointOfView?.addChildNode(cubeNode)
        self.placeState = PlaceState.placing(cubeNode)
    }
    
    
    func saveArtifact(cubeNode: CubeNode) {
        guard let location = sceneLocationView.currentLocation(),
              let position = sceneLocationView.currentScenePosition() else { return }
        
        let locationEstimate = SceneLocationEstimate(location: location, position: position)
        let artifactLocation = locationEstimate.translatedLocation(to: cubeNode.position)
        let distanceToGround = cubeNode.position.y
        
        try! realm.write {
            let artifact = Artifact()
            artifact.eulerX = cubeNode.eulerAngles.x
            artifact.eulerY = cubeNode.eulerAngles.y
            artifact.eulerZ = cubeNode.eulerAngles.z
            
            let block = Block()
            block.artifact = artifact
            block.latitude = artifactLocation.coordinate.latitude
            block.longitude = artifactLocation.coordinate.longitude
            block.altitude = artifactLocation.altitude
            block.horizontalAccuracy = artifactLocation.horizontalAccuracy
            block.verticalAccuracy = artifactLocation.verticalAccuracy
            block.groundDistance = CLLocationDistance(distanceToGround)
            block.createdAt = Date()
            block.hexColor = cubeNode.hexColor
            
            artifact.blocks.append(block)
            realm.add(artifact)
        }
    }
    
}
