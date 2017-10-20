//
//  ARViewController+ARSessionDelegate.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import ARKit

extension ARViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if case .placing(let cube) = placeState {
//            cube.eulerAngles.x = -frame.camera.eulerAngles.x
//            cube.eulerAngles.z = -frame.camera.eulerAngles.z - Float(Double.pi / 2)
            updatePlacingCube(cube)
        }
        
        if case .placing = placeState, case .editing = placeState {
            let bg = frame.capturedImage
            if let k1 = CVPixelBufferGetBaseAddressOfPlane(bg, 1) {
                let x1 = CVPixelBufferGetWidthOfPlane(bg, 1)
                let y1 = CVPixelBufferGetHeightOfPlane(bg, 1)
                memset(k1, 128, x1 * y1 * 2)
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            self.hudWindow?.hudController.cameraReady(true)
        default:
            self.hudWindow?.hudController.cameraReady(false)
        }
    }
    
    func updatePlacingCube(_ cube: CubePlaceableNode) {
//        if isObjectVisible {
//            focusSquare.hide()
//        } else {
//            focusSquare.unhide()
//            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
//        }
        
        // We should always have a valid world position unless the sceen is just being initialized.
        guard let (worldPosition, planeAnchor, _) = sceneLocationView.worldPosition(fromScreenPosition: screenCenter, objectPosition: cube.lastPosition) else {
            serialQueue.async {
                cube.state = .initializing
                self.sceneLocationView.pointOfView?.addChildNode(cube)
            }
            return
        }
        
        serialQueue.async {
//            self.sceneLocationView.scene.rootNode.addChildNode(cube)
            let camera = self.sceneLocationView.session.currentFrame?.camera
            
            if let planeAnchor = planeAnchor {
                cube.state = .planeDetected(anchorPosition: worldPosition, planeAnchor: planeAnchor, camera: camera)
            } else {
                cube.state = .featuresDetected(anchorPosition: worldPosition, camera: camera)
            }
        }
//        addObjectButton.isHidden = false
//        statusViewController.cancelScheduledMessage(for: .focusSquare)
    }
}
