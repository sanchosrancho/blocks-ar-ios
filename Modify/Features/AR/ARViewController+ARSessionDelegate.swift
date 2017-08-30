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
        if case .placing(let node) = placeState {
            node.eulerAngles.x = -frame.camera.eulerAngles.x
            node.eulerAngles.z = -frame.camera.eulerAngles.z - Float(Double.pi / 2)
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
    
}
