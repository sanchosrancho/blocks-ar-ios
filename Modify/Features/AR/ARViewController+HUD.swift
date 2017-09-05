//
//  ARViewController+HUD.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation

extension ARViewController: HUDViewControllerDelegate {
    
    func hudAddObjectPressed() {
        addArtifact(named: "rainbow")
    }
    
    func hudPlaceObjectPressed() {
        if case .placing(let object) = placeState {
            let t = object.node.worldTransform
            object.node.removeFromParentNode()
            object.node.transform = t
            saveArtifact(artifactNode: object)
            placeState = .none
        }
    }
    
    func hudPlaceObjectCancelled() {
        if case .placing(let object) = placeState {
            object.node.removeFromParentNode()
            placeState = .none
        }
    }
    
    
    func hudPlaceChangeDistance(_ value: Float) {
        if case .placing(let object) = placeState {
            var delta = zDistance - value
            delta = max(min(30, delta), 1)
            object.node.position.z = -delta
        }
    }
    
    func hudPlaceWillChangeDistance() {
        if case .placing(let object) = placeState {
            self.zDistance = -object.node.position.z
        }
    }
    
    
    func hudStopAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = false
    }
    
    func hudStartAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = true
    }
}
