//
//  ARViewController+HUD.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit
import SceneKit

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
    
    
    func hudDidTap(_ gesture: UITapGestureRecognizer, color: UIColor) {
        let point = gesture.location(in: sceneLocationView)
        let hitResults = sceneLocationView.hitTest(point, options: [:])
        guard let result = hitResults.first else { return }
        
        guard let block = result.node as? BlockNode else { return }
        guard let face = block.findFace(with: result.geometryIndex) else { return }
        
        let newPosition = block.newPosition(from: face)
        let newLocation = block.newLocation(for: newPosition)
        
        addCube(with: newLocation, toArtifact: block.artifactId, color: color, position: newPosition)
    }
    
    
    func hudDidChangeCurrentColor(_ color: UIColor) {
        guard case .placing(let cube) = placeState else { return }
        cube.updateColor(color)
    }
}
