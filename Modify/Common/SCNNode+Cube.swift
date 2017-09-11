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
    
    init(position: SCNVector3, hexColor: String) {
        super.init()
        
        let geometry = SCNBox(width: CubeNode.size, height: CubeNode.size, length: CubeNode.size, chamferRadius: CubeNode.chamfer)
        geometry.chamferSegmentCount = CubeNode.chamfersCount
        var materials = [SCNMaterial]()
        let color = UIColor.fromHex(hexColor)
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
    
    
    func newPosition(from face: CubeFace) -> SCNVector3 {
        var x = self.position.x
        var y = self.position.y
        var z = self.position.z
        let size = Float(CubeNode.size)
        switch face {
            case .front:  z += size
            case .back:   z -= size
            case .left:   x -= size
            case .right:  x += size
            case .top:    y += size
            case .bottom: y -= size
        }
        return SCNVector3(x, y, z)
    }
    
    
    //MARK: - Private
    
    private static let size: CGFloat = 0.1
    private static let chamfer: CGFloat = 0.002
    private static let chamfersCount = 2
    
    
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
