//
//  ARViewController+HUD.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit

extension ARViewController: HUDViewControllerDelegate {
    
    func hudAddObjectPressed(color: UIColor) {
        addInitialCubeToCamera(with: color)
    }
    
    
    func hudPlaceObjectPressed() {
        if case .placing(let cube) = placeState {
            let t = cube.worldTransform
            cube.removeFromParentNode()
            cube.transform = t
            saveArtifact(cubeNode: cube)
            placeState = .preview
        }
    }
    
    func hudPlaceObjectCancelled() {
        if case .placing(let cube) = placeState {
            cube.removeFromParentNode()
            placeState = .preview
        }
    }
    
    
    func hudPlaceChangeDistance(_ value: Float) {
        /*
        if case .placing(let object) = placeState {
            var delta = self.currentYPosition - value
            delta = max(min(20, delta), -20)
            object.node.position.y = delta
        }
        */
    }
    
    func hudPlaceWillChangeDistance() {
        /*
        if case .placing(let object) = placeState {
            self.currentYPosition = object.node.position.y
        }
        */
    }
    
    
    func hudStopAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = false
    }
    
    func hudStartAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = true
    }
}
