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
        
        Artifacts.create(location: artifactLocation,
            eulerX: cubeNode.eulerAngles.x,
            eulerY: cubeNode.eulerAngles.y,
            eulerZ: cubeNode.eulerAngles.z,
            distanceToGround: CLLocationDistance(cubeNode.position.y),
            color: cubeNode.hexColor)
    }
    
    
    func addCube(with location: CLLocation, toArtifact artifactId: String, color: UIColor, position: ArtifactPosition) {
        guard let artifact = realm.object(ofType: Artifact.self, forPrimaryKey: artifactId) else { return }
        
        try! realm.write {
            let block = Block()
            block.artifact = artifact
            
            block.x = position.x
            block.y = position.y
            block.z = position.z
            
            block.latitude = location.coordinate.latitude
            block.longitude = location.coordinate.longitude
            block.altitude = location.altitude
            
            block.createdAt = Date()
            block.hexColor = color.hexString()
            
            artifact.blocks.append(block)
        }
    }
}
