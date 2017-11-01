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
        if case .placing(let placeableCube) = placeState {
            serialQueue.async {
                placeableCube.falldown(complete: { /* [weak self] in */
                    let cube = placeableCube.cube
                    let t = cube.worldTransform
                    
                    placeableCube.removeFromParentNode()
                    cube.transform = t
                    
                    DispatchQueue.main.async {
                        self.saveArtifact(cubeNode: cube)
                        self.placeState = .preview
                    }
                })
            }
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
    
    
    func hudDidEndEditing() {
        self.placeState = .preview
    }
    
    
    func hudDidTapInPreview(gesture: UITapGestureRecognizer) {
        guard let result = hitResultFrom(tapGesture: gesture) else { return }
        guard let block = result.node as? BlockNode else { return }
        guard let artifactNode = block.parent as? ArtifactNode else { return }
        
        self.placeState = .editing(artifactNode)
    }
    
    
    func hudDidTapInEditing(gesture: UITapGestureRecognizer, color: UIColor, editMode: EditModeType) {
        guard let result = hitResultFrom(tapGesture: gesture) else { return }
        guard let block = result.node as? BlockNode else { return }
        
        guard case .editing(let artifactNode) = self.placeState else { return }
        guard artifactNode.artifactId == block.artifactId else { return }
        
        switch editMode {
        case .append:
            guard let face = block.findFace(with: result.geometryIndex) else { return }
            guard let newPosition = block.newPosition(from: face) else { return }
            let newLocation = block.newLocation(for: newPosition)
            addBlock(with: newLocation, toArtifact: block.artifactId, color: color, position: newPosition)
        case .delete:
            deleteBlock(with: block.objectId, latitude: block.lat, longitude: block.lon)
            break
        }
    }
    
    
    func hudDidChangeCurrentColor(_ color: UIColor) {
        guard case .placing(let placeableCube) = placeState else { return }
        placeableCube.cube.updateColor(color)
    }
    
    
    private func hitResultFrom(tapGesture: UITapGestureRecognizer) -> SCNHitTestResult? {
        let point = tapGesture.location(in: sceneLocationView)
        let hitResults = sceneLocationView.hitTest(point, options: [:])
        guard let result = hitResults.first else { return nil }
        return result
    }
}
