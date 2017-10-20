//
//  CubeNode.swift
//  Modify
//
//  Created by Олег Адамов on 05.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import SceneKit


enum CubeFace: Int {
    case front, right, back, left, top, bottom
}

class CubeNode: SCNNode {
    
    public static let size: Float = 0.1
    public var hexColor: String { return self.color.hexString() }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(position: SCNVector3, color: UIColor) {
        self.color = color
        
        super.init()
        
        let size = CGFloat(CubeNode.size)
        let geometry = SCNBox(width: size, height: size, length: size, chamferRadius: CubeNode.chamfer)
        geometry.chamferSegmentCount = CubeNode.chamfersCount
        var materials = [SCNMaterial]()
        for _ in 0..<6 {
            materials.append(getMaterial(with: color))
        }
        geometry.materials = materials
        self.geometry = geometry
        self.position = position
    }
    
    func findFace(with index: Int) -> CubeFace? {
        guard let materials = geometry?.materials, index < materials.count else { return nil }
        return CubeFace(rawValue: index)
    }
    
    func updateColor(_ color: UIColor) {
        self.color = color
        guard let materials = geometry?.materials, materials.count > 0 else { return }
        materials.forEach { $0.diffuse.contents = color }
    }
    
    
    //MARK: - Private
    
    private static let chamfer: CGFloat = 0.002
    private static let chamfersCount = 2
    private var color: UIColor
    
    private func getMaterial(with color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.locksAmbientWithDiffuse = true
        return material
    }
}
