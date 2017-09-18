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
        
        guard let block = result.node as? CubeNode /*BlockNode*/ else { return }
        guard let artifactNode = block.parent as? ArtifactNode else { return }
        guard let face = block.findFace(with: result.geometryIndex) else { return }
        let newPos = block.newPosition(from: face)
        let translation = LocationTranslation(latitudeTranslation: -Double(newPos.z), longitudeTranslation: -Double(newPos.x), altitudeTranslation: -Double(newPos.y))
        let newLocation = artifactNode.location.translatedLocation(with: translation)
        
        let tr = newLocation.translation(toLocation: artifactNode.location)
        let testPos = SCNVector3(tr.longitudeTranslation, tr.altitudeTranslation, tr.latitudeTranslation)
        
        let blockNode = CubeNode(position: testPos, color: color)
        artifactNode.addChildNode(blockNode)
//        addCube(with: newLocation, to: artifactNode.artifactId, color: color)
        
    }
}
