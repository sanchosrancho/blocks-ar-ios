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
    
    func addInitialCube() {
        let cubeNode = CubeNode(position: SCNVector3(0, 0, zDistance), color: .white)
        sceneLocationView.pointOfView?.addChildNode(cubeNode)
        self.placeState = PlaceState.placing(cubeNode)
    }
    
    
    func saveArtifact(artifactNode object: ArtifactNode) {
        /*
        guard let currentLocation = sceneLocationView.currentLocation(),
              let currentPosition = sceneLocationView.currentScenePosition() else { return }
        
        let currentLocationEstimate = SceneLocationEstimate(location: currentLocation, position: currentPosition)
         let artifactLocation = currentLocationEstimate.translatedLocation(to: object.node.position)
         let distanceToGround = object.node.position.y
        
        try! realm.write {
            let artifact = Artifact()
            artifact.modelName = object.name
            artifact.lat = artifactLocation.coordinate.latitude
            artifact.lon = artifactLocation.coordinate.longitude
            artifact.alt = artifactLocation.altitude
            artifact.horizontalAccuracy = artifactLocation.horizontalAccuracy
            artifact.verticalAccuracy = artifactLocation.verticalAccuracy
            artifact.groundDistance = CLLocationDistance(distanceToGround)
            artifact.createdAt = NSDate()
            artifact.eulerX = object.node.eulerAngles.x
            artifact.eulerY = object.node.eulerAngles.y
            artifact.eulerZ = object.node.eulerAngles.z
            realm.add(artifact)
        }
        */
    }
    
}
