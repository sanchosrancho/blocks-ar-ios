//
//  CubePlaceableNode.swift
//  Modify
//
//  Created by Alex Shevlyakov on 20/10/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import ARKit

protocol NodePlaceable {
    var state: NodePlaceableState { get }
}

enum NodePlaceableState {
    case initializing
    case featuresDetected(anchorPosition: float3, camera: ARCamera?)
    case planeDetected(anchorPosition: float3, planeAnchor: ARPlaneAnchor, camera: ARCamera?)
}

class CubePlaceableNode: CubeNode, NodePlaceable {
    
    var lastPosition: float3? {
        switch state {
        case .initializing: return nil
        case .featuresDetected(let anchorPosition, _): return anchorPosition
        case .planeDetected(let anchorPosition, _, _): return anchorPosition
        }
    }
    
    var state: NodePlaceableState = .initializing {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initializing:
//                displayAsBillboard()
//                displayAsOpen(at: anchorPosition, camera: camera)
                break
                
            case .featuresDetected(let anchorPosition, let camera):
                displayOnGround(at: anchorPosition, camera: camera)
                
            case .planeDetected(let anchorPosition, let planeAnchor, let camera):
//                displayAsClosed(at: anchorPosition, planeAnchor: planeAnchor, camera: camera)
                displayOnGround(at: anchorPosition, camera: camera)
            }
        }
    }
    
    /// The cube's most recent positions.
    private var recentPositions: [float3] = []
    
    private var onTheGround: Bool = false
    private var cubeLevitationHeight = 0.2
    
    // MARK: Appearance
    
    /// Called when a surface has been detected.
    private func displayOnGround(at position: float3, camera: ARCamera?) {
//        performOpenAnimation()
//        performShowThumb()
        recentPositions.append(position)
        updateTransform(for: position, camera: camera)
    }
    
    // MARK: Animations
    
    private func falldown() {
        let correctionFactor = FocusSquare.thickness / 2 // correction to align lines perfectly
        let length = 1.0 - FocusSquare.thickness * 2 + correctionFactor
        let currentPosition = thumbBlock.position
        let groundPosition = SCNVector3(x: currentPosition.x, y: currentPosition.y, z: -length/2.0)
        let flyPosition = SCNVector3(x: currentPosition.x, y: currentPosition.y, z: -length)
        
        if onTheGround {
            onTheGround = false
            
            self.thumbBlock.runAction(blockMove(to: flyPosition)) {
                self.thumbBlock.runAction(levitationAction(), forKey: "levitation")
            }
            self.occlusionShadow.runAction(.group([
                shadowIntensityAction(from: 0.6, to: 0.4),
                shadowScaleAction(from: 1.04, to: 1.2)
                ]))
            
        } else {
            onTheGround = true
            thumbBlock.removeAction(forKey: "levitation")
            
            
            self.thumbBlock.runAction(blockMove(to: groundPosition)) {
                self.thumbBlock.runAction(levitationAction(), forKey: "levitation")
            }
            self.occlusionShadow.runAction(.group([
                shadowIntensityAction(from: 0.4, to: 0.6),
                shadowScaleAction(from: 1.2, to: 1.04)
                ]))
        }
    }
    
    private func blockMove(to position: SCNVector3) -> SCNAction {
        let fallDownAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z), duration: 0.4)
        let bounceUpAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z - 0.04), duration: 0.08)
        let bounceDownAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z), duration: 0.08)
        fallDownAction.timingMode = .easeIn
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        return .sequence([fallDownAction, bounceUpAction, bounceDownAction])
    }
    
    private func shadowIntensityAction(from: CGFloat, to: CGFloat) -> SCNAction {
        let fallDownAction = SCNAction.fadeOpacity(to: to, duration: 0.4)
        let bounceUpAction = SCNAction.fadeOpacity(to: to - (from - to)*(0.08/0.4), duration: 0.08)
        let bounceDownAction = SCNAction.fadeOpacity(to: to, duration: 0.08)
        fallDownAction.timingMode = .easeIn
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        return .sequence([fallDownAction, bounceUpAction, bounceDownAction])
    }
    
    private func shadowScaleAction(from: CGFloat, to: CGFloat) -> SCNAction {
        let fallDownAction = SCNAction.scale(to: to, duration: 0.4)
        let bounceUpAction = SCNAction.scale(to: to - (from - to)*(0.08/0.4), duration: 0.08)
        let bounceDownAction = SCNAction.scale(to: to, duration: 0.08)
        fallDownAction.timingMode = .easeIn
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        return .sequence([fallDownAction, bounceUpAction, bounceDownAction])
    }
    
    private func falldownAction(to position: SCNVector3) -> SCNAction {
        // todo: use math
        // https://www.smashingmagazine.com/2011/10/quick-look-math-animations-javascript/
        // https://github.com/chenglou/tween-functions/blob/master/index.js
        // https://github.com/luowenxing/TFAnimation/blob/master/TFAnimation/TFAnimation/TFEasingFunction.swift
        // http://www.cocoawithlove.com/2008/09/parametric-acceleration-curves-in-core.html
        
        let fallDownAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z), duration: 0.4)
        let bounceUpAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z - 0.04), duration: 0.08)
        let bounceDownAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z), duration: 0.08)
        fallDownAction.timingMode = .easeIn
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        return .sequence([fallDownAction, bounceUpAction, bounceDownAction])
    }
    
    private func levitationAction() -> SCNAction {
        let moveUpAction = SCNAction.move(by: SCNVector3(0, 0, 0.125), duration: 2.0)
        let moveDownAction = SCNAction.move(by: SCNVector3(0, 0, -0.125), duration: 2.0)
        moveUpAction.timingMode = .easeInEaseOut
        moveDownAction.timingMode = .easeInEaseOut
        return SCNAction.repeatForever(SCNAction.sequence([moveUpAction, moveDownAction]))
    }
    
    // MARK: Helper Methods
    
    /// Update the transform of the focus square to be aligned with the camera.
    private func updateTransform(for position: float3, camera: ARCamera?) {
//        guard let camera = camera else { return }
//        eulerAngles.x = -camera.eulerAngles.x
//        eulerAngles.z = -camera.eulerAngles.z - Float(Double.pi / 2)
//        return
        simdTransform = matrix_identity_float4x4

        // Average using several most recent positions.
        recentPositions = Array(recentPositions.suffix(10))

        // Move to average of recent positions to avoid jitter.
        let average = recentPositions.reduce(float3(0), { $0 + $1 }) / Float(recentPositions.count)
        self.simdPosition = average
        self.simdScale = float3(scaleBasedOnDistance(camera: camera))

        // Correct y rotation of camera square.
        guard let camera = camera else { return }
        let tilt = abs(camera.eulerAngles.x)
        let threshold1: Float = .pi / 2 * 0.65
        let threshold2: Float = .pi / 2 * 0.75
        let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
        var angle: Float = 0

        switch tilt {
        case 0..<threshold1:
            angle = camera.eulerAngles.y

        case threshold1..<threshold2:
            let relativeInRange = abs((tilt - threshold1) / (threshold2 - threshold1))
            let normalizedY = normalize(camera.eulerAngles.y, forMinimalRotationTo: yaw)
            angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange

        default:
            angle = yaw
        }
        eulerAngles.y = angle
    }
    
    private func normalize(_ angle: Float, forMinimalRotationTo ref: Float) -> Float {
        // Normalize angle in steps of 90 degrees such that the rotation to the other angle is minimal
        var normalized = angle
        while abs(normalized - ref) > .pi / 4 {
            if angle > ref {
                normalized -= .pi / 2
            } else {
                normalized += .pi / 2
            }
        }
        return normalized
    }
    
    /**
     Reduce visual size change with distance by scaling up when close and down when far away.
     
     These adjustments result in a scale of 1.0x for a distance of 0.7 m or less
     (estimated distance when looking at a table), and a scale of 1.2x
     for a distance 1.5 m distance (estimated distance when looking at the floor).
     */
    private func scaleBasedOnDistance(camera: ARCamera?) -> Float {
        guard let camera = camera else { return 1.0 }
        
        let distanceFromCamera = simd_length(simdWorldPosition - camera.transform.translation)
        if distanceFromCamera < 0.7 {
            return distanceFromCamera / 0.7
        } else {
            return 0.25 * distanceFromCamera + 0.825
        }
    }
    
}


extension NodePlaceableState: Equatable {
    static func ==(lhs: NodePlaceableState, rhs: NodePlaceableState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing):
            return true
            
        case (.featuresDetected(let lhsPosition, let lhsCamera),
              .featuresDetected(let rhsPosition, let rhsCamera)):
            return lhsPosition == rhsPosition && lhsCamera == rhsCamera
            
        case (.planeDetected(let lhsPosition, let lhsPlaneAnchor, let lhsCamera),
              .planeDetected(let rhsPosition, let rhsPlaneAnchor, let rhsCamera)):
            return lhsPosition == rhsPosition
                && lhsPlaneAnchor == rhsPlaneAnchor
                && lhsCamera == rhsCamera
            
        default:
            return false
        }
    }
}

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
