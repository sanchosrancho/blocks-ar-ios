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
            var delta = self.currentYPosition - value
            delta = max(min(20, delta), -20)
            object.node.position.y = delta
        }
    }
    
    func hudPlaceWillChangeDistance() {
        if case .placing(let object) = placeState {
            self.currentYPosition = object.node.position.y
        }
    }
    
    
    func hudStopAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = false
    }
    
    func hudStartAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = true
    }
}
