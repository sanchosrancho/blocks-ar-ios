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
    private var cubeGroundPosition: SCNVector3 { return SCNVector3(x: 0, y: CubeNode.size/2, z: 0) }
    private var cubeFlyPosition: SCNVector3 { return SCNVector3(x: 0, y: CubeNode.size*1.5, z: 0) }
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
        
        self.addChildNode(castShadow)
        self.addChildNode(occlusionShadow)
        self.addChildNode(cube)
        
        castShadow.position = SCNVector3(0, -0.000001, 0)
        
//        castShadow.renderingOrder = -2
//        occlusionShadow.renderingOrder = -1
     
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
        let shadowLayerLength:CGFloat = 14.0
        
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
        
        layerOuter.frame = CGRect(x: 0, y: 0, width: shadowLayerLength*2, height: shadowLayerLength*2)
        layerInner.frame = CGRect(x: shadowLayerLength/2, y: shadowLayerLength/2, width: shadowLayerLength, height: shadowLayerLength)
        
        layerInner.backgroundColor = UIColor.black.cgColor
        
        UIGraphicsBeginImageContextWithOptions(layerOuter.bounds.size, false, 2.0);
        layerOuter.render(in: UIGraphicsGetCurrentContext()!)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        let material = plane.firstMaterial!
        material.diffuse.contents = img
        material.cullMode = .front
        material.isDoubleSided = true
//        material.readsFromDepthBuffer = false
//        material.ambient.contents = UIColor.black
//        material.lightingModel = .constant
//        material.emission.contents = FocusSquare.fillColor
        
        return node
    }()
    
    private lazy var castShadow: SCNNode = {
        let shadowLayerLength:CGFloat = 2.2
        
        let plane = SCNPlane(width: CGFloat(CubeNode.size * 4.0), height: CGFloat(CubeNode.size * 4.0))
        let node = SCNNode(geometry: plane)
        node.name = "castShadow"
        node.opacity = 0.3
        node.castsShadow = false
        node.eulerAngles.x = .pi / 2
        
        
        let layerOuter = CALayer()
        let layerInner = CALayer()
        layerOuter.addSublayer(layerInner)
        
        layerOuter.frame = CGRect(x: 0, y: 0, width: shadowLayerLength*2, height: shadowLayerLength*2)
        layerInner.frame = CGRect(x: shadowLayerLength/2, y: shadowLayerLength/2, width: shadowLayerLength, height: shadowLayerLength)
        
        layerInner.backgroundColor = UIColor.black.cgColor
        
        UIGraphicsBeginImageContextWithOptions(layerOuter.bounds.size, false, 2.0);
        layerOuter.render(in: UIGraphicsGetCurrentContext()!)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        let material = plane.firstMaterial!
        material.diffuse.contents = img
        material.cullMode = .front
        material.isDoubleSided = true
//        material.readsFromDepthBuffer = false
        
        return node
    }()
    
    
    // MARK: Animations
    
    private var isShown: Bool = false
    private func performAnimation() {
        guard !isShown else { return }
        isShown = true
        let fadeInAction = SCNAction.fadeOpacity(to: 1, duration: 0.3)
        self.runAction(fadeInAction)
    }
    
    public func falldown(complete completionHandler: (() -> Void)? = nil) {
        if isCubeOnGround {
            isCubeOnGround = false
            runMove(to: cubeFlyPosition.y, complete: { self.levitation() })
        } else {
            isCubeOnGround = true
            cube.removeAction(forKey: "levitation")
            occlusionShadow.removeAction(forKey: "levitation")
            castShadow.removeAction(forKey: "levitation")
            runFalldown(to: cubeGroundPosition.y, complete: completionHandler)
        }
    }
    
    private func levitation() {
        let duration: TimeInterval = 2.0
        let durations = [duration, duration]
        let stages = [cubeFlyPosition.y + 0.025, cubeFlyPosition.y - 0.025]
        
        var castShadowAppearances: [ShadowAppearance] = []
        var occlusionShadowAppearances: [ShadowAppearance] = []
        for stage in stages {
            let shadow = shadowForCube(atHeight: stage)
            castShadowAppearances.append(shadow.cast)
            occlusionShadowAppearances.append(shadow.occlusion)
        }
        
        print("stages", stages)
        print("occlusionShadowAppearances", occlusionShadowAppearances)
        print("castShadowAppearances", castShadowAppearances)
        
        cube.runAction(.repeatForever(
            cubeMoveAction(to: stages, inTime: durations, withTimingFunctions: [.easeInEaseOut, .easeInEaseOut])
        ), forKey: "levitation")
        
        castShadow.runAction(.repeatForever(
            shadowAction(appearances: castShadowAppearances, durations: durations, timingModes: [.easeOut, .easeIn])
        ), forKey: "levitation")
        
        occlusionShadow.runAction(.repeatForever(
            shadowAction(appearances: occlusionShadowAppearances, durations: durations, timingModes: [.easeOut, .easeIn])
        ), forKey: "levitation")
    }
    
    private func runFalldown(to: Float, complete: (() -> Void)? = nil) {
        let stages: [Float] = [to, to + 0.008, to]
        let durations: [TimeInterval] = [0.4, 0.08, 0.08]
        let timings: [SCNActionTimingMode] = [.easeIn, .easeOut, .easeIn]
        
        var castShadowAppearances: [ShadowAppearance] = []
        var occlusionShadowAppearances: [ShadowAppearance] = []
        for stage in stages {
            let shadow = shadowForCube(atHeight: stage)
            castShadowAppearances.append(shadow.cast)
            occlusionShadowAppearances.append(shadow.occlusion)
        }
        
        cube.runAction(cubeMoveAction(to: stages, inTime: durations, withTimingFunctions: timings)) {
            complete?()
        }
        castShadow.runAction(shadowAction(appearances: castShadowAppearances, durations: durations, timingModes: timings))
        occlusionShadow.runAction(shadowAction(appearances: occlusionShadowAppearances, durations: durations, timingModes: timings))
    }
    
    private func runMove(to: Float, complete completionHandler: (() -> Void)? = nil) {
        let stages: [Float] = [to]
        let durations: [TimeInterval] = [0.4]
        let timings: [SCNActionTimingMode] = [.easeInEaseOut]
        
        var castShadowAppearances: [ShadowAppearance] = []
        var occlusionShadowAppearances: [ShadowAppearance] = []
        for stage in stages {
            let shadow = shadowForCube(atHeight: stage)
            castShadowAppearances.append(shadow.cast)
            occlusionShadowAppearances.append(shadow.occlusion)
        }
        
        cube.runAction(cubeMoveAction(to: stages, inTime: durations, withTimingFunctions: timings)) {
            completionHandler?()
        }
        castShadow.runAction(shadowAction(appearances: castShadowAppearances, durations: durations, timingModes: timings))
        occlusionShadow.runAction(shadowAction(appearances: occlusionShadowAppearances, durations: durations, timingModes: timings))
    }
    
    private func cubeMoveAction(to positions: [Float], inTime durations: [TimeInterval], withTimingFunctions timings: [SCNActionTimingMode]) -> SCNAction {
        let moveAction = { (position: CGFloat, duration: TimeInterval) -> SCNAction in
            SCNAction.move(to: SCNVector3(0.0, position, 0.0), duration: duration)
        }
        return generateSequenceAction(stages: positions.map { CGFloat($0) }, durations: durations, timingModes: timings, action: moveAction)
    }
    
    private func shadowAction(appearances: [ShadowAppearance], durations: [TimeInterval], timingModes: [SCNActionTimingMode]) -> SCNAction {
        let intensities = appearances.map { $0.intensity }
        let scales = appearances.map { $0.scale }
        let fadeInAction = { SCNAction.fadeOpacity(to: $0, duration: $1) }
        let scaleAction  = { SCNAction.scale(to: $0, duration: $1) }
        return SCNAction.repeatForever(
            SCNAction.group([
                generateSequenceAction(stages: intensities, durations: durations, timingModes: timingModes, action: fadeInAction),
                generateSequenceAction(stages: scales,      durations: durations, timingModes: timingModes, action: scaleAction)
            ])
        )
    }
    
    struct ShadowAppearance {
        let intensity: CGFloat
        let scale: CGFloat
    }
    
    struct CubeShadow {
        let cast: ShadowAppearance
        let occlusion: ShadowAppearance
    }
    
    private func shadowForCube(atHeight height: Float) -> CubeShadow {
        func shadowAppearanceInterpolatedForPoint(_ point: CGFloat, intensities: (CGFloat, CGFloat), scales: (CGFloat, CGFloat)) -> ShadowAppearance {
            return ShadowAppearance(
                intensity: point * (intensities.1 - intensities.0) + intensities.0,
                scale: point * (scales.1 - scales.0) + scales.0
            )
        }
        
        let positions: (CGFloat, CGFloat) = (0, CGFloat(cubeFlyPosition.y))
        let castIntensities: (CGFloat, CGFloat) = (0.0, 0.3)
        let castScales: (CGFloat, CGFloat) = (0.9, 0.61)
        let occlusionIntensities: (CGFloat, CGFloat) = (0.98, 0.18)
        let occlusionScales: (CGFloat, CGFloat) = (0.938, 1.14)
        
        let positionFactor = (CGFloat(height) - positions.0) / (positions.1 - positions.0)
        
        return CubeShadow(
            cast: shadowAppearanceInterpolatedForPoint(positionFactor, intensities: castIntensities, scales: castScales),
            occlusion: shadowAppearanceInterpolatedForPoint(positionFactor, intensities: occlusionIntensities, scales: occlusionScales)
        )
    }
    
    private func generateSequenceAction(stages: [CGFloat], durations: [TimeInterval], timingModes: [SCNActionTimingMode], action: (CGFloat, TimeInterval) -> SCNAction) -> SCNAction {
        var actions: [SCNAction] = []
        for (index, value) in stages.enumerated() {
            let action = action(value, durations[index])
            action.timingMode = timingModes[index]
            actions.append(action)
        }
        return .sequence(actions)
    }
    
    // MARK: Convinience Methods
    
    /// Sets the rendering order of the node to show on top or under other scene content.
    func displayNodeHierarchyOnTop(_ isOnTop: Bool) {
        // Recursivley traverses the node's children to update the rendering order depending on the `isOnTop` parameter.
        func updateRenderOrder(for node: SCNNode) {
            node.renderingOrder = isOnTop ? 2 : 0
            
            for material in node.geometry?.materials ?? [] {
                material.readsFromDepthBuffer = !isOnTop
            }
            
            for child in node.childNodes {
                updateRenderOrder(for: child)
            }
        }
        
        updateRenderOrder(for: self)
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
        print("yaw", yaw, "angle: ", angle)
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
