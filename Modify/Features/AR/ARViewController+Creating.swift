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
        case none
        case placing(ArtifactNode)
    }
    
    
    func addArtifact(named name: String) {
        guard let object = ArtifactNode(name: name) else { return }
        object.node.position = SCNVector3(0, 0, zDistance)
        sceneLocationView.pointOfView?.addChildNode(object.node)
        self.placeState = PlaceState.placing(object)
    }
    
    
    func saveArtifact(artifactNode object: ArtifactNode) {
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
    }
    
}
