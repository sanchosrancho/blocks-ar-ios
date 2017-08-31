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
        addArtifact()
    }
    
    func hudPlaceObjectPressed() {
        if case .placing(let node) = placeState {
            let t = node.worldTransform
            node.removeFromParentNode()
            node.transform = t
            saveArtifact(withPosition: node.position, andAngles: node.eulerAngles)
            placeState = .none
        }
    }
    
    func hudPlaceObjectCancelled() {
        if case .placing(let node) = placeState {
            node.removeFromParentNode()
            placeState = .none
        }
    }
    
    func hudStopAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = false
    }
    
    func hudStartAdjustingNodesPosition() {
        sceneLocationView.shouldUpdateLocationEstimate = true
    }
}
