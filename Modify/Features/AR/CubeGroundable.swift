//
//  CubeGroundable.swift
//  Modify
//
//  Created by Alex Shevlyakov on 20/10/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import ARKit

protocol NodeGroundable {
    var state: PlainDetectionState { get }
}

enum PlainDetectionState {
    case initializing
    case featuresDetected(anchorPosition: float3, camera: ARCamera?)
    case planeDetected(anchorPosition: float3, planeAnchor: ARPlaneAnchor, camera: ARCamera?)
}

class CubeGroundable: SCNNode, NodeGroundable {
    
    public let cube: CubeNode
    private var cubeGroundPosition: SCNVector3 { return SCNVector3(x: 0, y: -CubeNode.size/2, z: 0) }
    private var cubeFlyPosition: SCNVector3 { return SCNVector3(x: 0, y: CubeNode.size/2, z: 0) }
    private var isCubeOnGround: Bool = true
    
    var lastPosition: float3? {
        switch state {
        case .initializing: return nil
        case .featuresDetected(let anchorPosition, _): return anchorPosition
        case .planeDetected(let anchorPosition, _, _): return anchorPosition
        }
    }
    
    var state: PlainDetectionState = .initializing {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initializing:
//                displayAsBillboard()
//                display(at: anchorPosition, camera: camera)
                break
                
            case .featuresDetected(let anchorPosition, let camera):
                display(at: anchorPosition, camera: camera)
                
            case .planeDetected(let anchorPosition, let planeAnchor, let camera):
//                displayAsClosed(at: anchorPosition, planeAnchor: planeAnchor, camera: camera)
                display(at: anchorPosition, camera: camera)
            }
        }
    }
    
    /// The focus square's most recent positions.
    private var recentPositions: [float3] = []
    
    
    // MARK: - Initialization
    
    init(_ cube: CubeNode) {
        self.cube = cube
        super.init()
        
        self.simdPosition = cube.simdPosition
        cube.simdTransform = matrix_identity_float4x4
        cube.position = cubeFlyPosition
        
        self.opacity = 0
        
//        simdScale = float3(CubeNode.size)
        self.addChildNode(occlusionShadow)
        self.addChildNode(cube)
     
        falldown()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    
    // MARK: Appearance
    
    /// Called when a surface has been detected.
    private func display(at position: float3, camera: ARCamera?) {
        performAnimation()
        recentPositions.append(position)
        updateTransform(for: position, camera: camera)
    }
    
    private lazy var occlusionShadow: SCNNode = {
//        let correctionFactor = FocusSquare.thickness / 2
//        let length = CGFloat(1.0 - FocusSquare.thickness * 2 + correctionFactor)
        let length2:CGFloat = 200.0
        
        let plane = SCNPlane(width: CGFloat(CubeNode.size * 2.0), height: CGFloat(CubeNode.size * 2.0))
        let node = SCNNode(geometry: plane)
        node.name = "occlusionShadow"
        node.opacity = 1.0
        node.castsShadow = false
//        node.position = SCNVector3(0, 0.002, 0) //-length/2)
        node.eulerAngles.x = .pi / 2
        
        
        let layerOuter = CALayer()
        let layerInner = CALayer()
        layerOuter.addSublayer(layerInner)
        
        layerOuter.frame = CGRect(x: 0, y: 0, width: length2*2, height: length2*2)
        layerInner.frame = CGRect(x: length2/2, y: length2/2, width: length2, height: length2)
        
        layerInner.backgroundColor = UIColor.black.cgColor
        
        UIGraphicsBeginImageContextWithOptions(layerOuter.bounds.size, false, 2.0);
        layerOuter.render(in: UIGraphicsGetCurrentContext()!)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        let material = plane.firstMaterial!
        material.diffuse.contents = img // UIColor.white // FocusSquare.fillColor
        material.cullMode = .front
        material.isDoubleSided = true
//        material.ambient.contents = UIColor.black
//        material.lightingModel = .constant
//        material.emission.contents = FocusSquare.fillColor
        
        return node
    }()
    
    
    // MARK: Animations
    
    private var isShown: Bool = false
    private func performAnimation() {
        guard !isShown else { return }
        isShown = true
        let fadeInAction = SCNAction.fadeOpacity(to: 1, duration: 0.3)
        self.runAction(fadeInAction)
//        occlusionShadow.opacity = 1.0
    }
    
    public func falldown() {
        if isCubeOnGround {
            isCubeOnGround = false
            
            cube.runAction(moveAction(to: cubeFlyPosition)) {
                self.cube.runAction(self.levitationAction(), forKey: "levitation")
            }
            occlusionShadow.runAction(shadowAppearanceAction(from: cube.position, to: cubeFlyPosition))
//            occlusionShadow.runAction(.group([
//                shadowIntensityAction(from: 0.6, to: 0.4),
//                shadowScaleAction(from: 1.04, to: 1.2)
//            ]))
            
        } else {
            isCubeOnGround = true
            cube.removeAction(forKey: "levitation")
            
            cube.runAction(moveAction(to: cubeGroundPosition)) {
                self.cube.runAction(self.levitationAction(), forKey: "levitation")
            }
            occlusionShadow.runAction(shadowAppearanceAction(from: cube.position, to: cubeGroundPosition))
        }
    }
    
    private func moveAction(to position: SCNVector3) -> SCNAction {
        let fallDownAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z), duration: 0.4)
        let bounceUpAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y - 0.04, z: position.z), duration: 0.08)
        let bounceDownAction = SCNAction.move(to: SCNVector3(x: position.x, y: position.y, z: position.z), duration: 0.08)
        fallDownAction.timingMode = .easeIn
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        return .sequence([fallDownAction, bounceUpAction, bounceDownAction])
    }
    
    private func levitationAction() -> SCNAction {
        let moveUpAction = SCNAction.move(by: SCNVector3(0, 0.125, 0), duration: 2.0)
        let moveDownAction = SCNAction.move(by: SCNVector3(0, -0.125, 0), duration: 2.0)
        moveUpAction.timingMode = .easeInEaseOut
        moveDownAction.timingMode = .easeInEaseOut
        return SCNAction.repeatForever(SCNAction.sequence([moveUpAction, moveDownAction]))
    }
    
    private func shadowAppearanceForCube(atHeight height: Float) -> (intensity: CGFloat, scale: CGFloat) {
        let positionRange: ClosedRange<CGFloat> = 0 ... CGFloat(CubeNode.size)
        let intesityRange: ClosedRange<CGFloat> = 0.4 ... 0.6
        let scaleRange: ClosedRange<CGFloat> = 1.04 ... 1.2
        let positionFactor: CGFloat = CGFloat(height) / (positionRange.upperBound - positionRange.lowerBound)
        
        return (
            intensity: (intesityRange.upperBound - intesityRange.lowerBound) * positionFactor + intesityRange.lowerBound,
            scale: (scaleRange.upperBound - scaleRange.lowerBound) * positionFactor + scaleRange.lowerBound
        )
    }
    
    private func shadowSequenceAction(values: [CGFloat], durations: [TimeInterval], timingModes: [SCNActionTimingMode], action: (CGFloat, TimeInterval) -> SCNAction) -> SCNAction {
        var actions: [SCNAction] = []
        for (index, value) in values.enumerated() {
            let action = action(value, durations[index])
            action.timingMode = timingModes[index]
            actions.append(action)
        }
        return .sequence(actions)
    }
    
    private func shadowAppearanceAction(from: SCNVector3, to: SCNVector3) -> SCNAction {
        let shadowEnd = shadowAppearanceForCube(atHeight: to.y)
        let shadowBounceUp = shadowAppearanceForCube(atHeight: from.y + (to.y - from.y)*(0.08/0.4))
        
        let values = [shadowEnd.intensity, shadowBounceUp.intensity, shadowEnd.intensity]
        let durations = [0.4, 0.08, 0.08]
        let timingModes: [SCNActionTimingMode] = [.easeIn, .easeOut, .easeIn]
        
        let fadeInAction = { SCNAction.fadeOpacity(to: $0, duration: $1) }
        let scaleAction  = { SCNAction.scale(to: $0, duration: $1) }
        
        return .group([
                shadowSequenceAction(values: values, durations: durations, timingModes: timingModes, action: fadeInAction),
                shadowSequenceAction(values: values, durations: durations, timingModes: timingModes, action: scaleAction)
            ])
    }
    
    
    // MARK: Helper Methods
    
    /// Update the transform of the focus square to be aligned with the camera.
    private func updateTransform(for position: float3, camera: ARCamera?) {
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


extension PlainDetectionState: Equatable {
    static func ==(lhs: PlainDetectionState, rhs: PlainDetectionState) -> Bool {
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
