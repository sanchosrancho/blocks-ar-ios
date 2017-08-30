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
        case placing(SCNNode)
    }
    
    func addArtifact() {
//        let scene = SCNScene(named: "art.scnassets/mr.pig.scn")!
//        let object = scene.rootNode.childNode(withName: "pig", recursively: true)!
        let scene = SCNScene(named: "art.scnassets/lips/lips.scn")!
        let object = scene.rootNode.childNode(withName: "lips", recursively: true)!
        object.scale = SCNVector3(0.015, 0.015, 0.015)
        object.position = SCNVector3(0, 0, -2)
        sceneLocationView.pointOfView?.addChildNode(object)
        self.placeState = PlaceState.placing(object)
        
//        let ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.childNode(withName: "ship", recursively: true)!
//        ship.position = SCNVector3(0, 0, -2)
//        sceneLocationView.pointOfView?.addChildNode(ship)
//        self.placeState = PlaceState.placing(ship)
    }
    
    func saveArtifact(withPosition artifactPosition: SCNVector3, andAngles eulerAngles: SCNVector3) {
        guard
            let currentLocation = sceneLocationView.currentLocation(),
            let currentPosition = sceneLocationView.currentScenePosition()
            else {
                return
        }
        
        let currentLocationEstimate = SceneLocationEstimate(location: currentLocation, position: currentPosition)
        let artifactLocation = currentLocationEstimate.translatedLocation(to: artifactPosition)
        let distanceToGround = artifactPosition.y
        
        try! realm.write {
            let artifact = Artifact()
            artifact.lat = artifactLocation.coordinate.latitude
            artifact.lon = artifactLocation.coordinate.longitude
            artifact.alt = artifactLocation.altitude
            artifact.horizontalAccuracy = artifactLocation.horizontalAccuracy
            artifact.verticalAccuracy = artifactLocation.verticalAccuracy
            artifact.groundDistance = CLLocationDistance(distanceToGround)
            artifact.createdAt = NSDate()
            artifact.eulerX = eulerAngles.x
            artifact.eulerY = eulerAngles.y
            artifact.eulerZ = eulerAngles.z
            realm.add(artifact)
        }
    }
    
}
