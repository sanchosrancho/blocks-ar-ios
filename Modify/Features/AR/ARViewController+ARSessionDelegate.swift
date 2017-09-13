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
            cube.eulerAngles.x = -frame.camera.eulerAngles.x
            cube.eulerAngles.z = -frame.camera.eulerAngles.z - Float(Double.pi / 2)
        }
        
        let bg = frame.capturedImage
        if let k1 = CVPixelBufferGetBaseAddressOfPlane(bg, 1) {
            let x1 = CVPixelBufferGetWidthOfPlane(bg, 1)
            let y1 = CVPixelBufferGetHeightOfPlane(bg, 1)
            memset(k1, 128, x1 * y1 * 2)
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
