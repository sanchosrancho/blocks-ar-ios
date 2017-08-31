//
//  ARViewController+SceneLocationViewDelegate.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import CoreLocation
import SceneKit

extension ARViewController: SceneLocationViewDelegate {
    
    func sceneLocationViewDidUpdateRenderer() {
        if let lightEstimate = sceneLocationView.session.currentFrame?.lightEstimate {
            sceneLocationView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: serialQueue)
        } else {
            sceneLocationView.scene.enableEnvironmentMapWithIntensity(40, queue: serialQueue)
        }
    }
    
    func sceneLocationViewDidUpdateLocation(sceneLocationView: SceneLocationView, location: CLLocation) {
        Application.sharedInstance.locationHorizontalAccuracy = location.horizontalAccuracy
        Application.sharedInstance.locationVerticalAccuracy   = location.verticalAccuracy
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {}
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {}
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {}
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {}
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {}
}
