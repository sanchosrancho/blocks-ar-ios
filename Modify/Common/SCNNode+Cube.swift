//
//  SCNNode+Cube.swift
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
    
    static let size: CGFloat = 0.1
    var hexColor: String {
        return self.color.hexString()
    }
    
    convenience init(dx: Int32, dy: Int32, dz: Int32, color: UIColor) {
        let size = CubeNode.size
        let position = SCNVector3(size * CGFloat(dx), size * CGFloat(dy), size * CGFloat(dz))
        self.init(position: position, color: color)
    }
    
    
    init(position: SCNVector3, color: UIColor) {
        self.color = color
        
        super.init()
        
        let geometry = SCNBox(width: CubeNode.size, height: CubeNode.size, length: CubeNode.size, chamferRadius: CubeNode.chamfer)
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
        guard let materials = geometry?.materials, materials.count > 0 else { return }
        materials.forEach { $0.diffuse.contents = color }
    }
    
    
    //MARK: - Private
    
    private static let chamfer: CGFloat = 0.002
    private static let chamfersCount = 2
    
    private let color: UIColor
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func getMaterial(with color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.locksAmbientWithDiffuse = true
        return material
    }
}
