//
//  BlockNode.swift
//  Modify
//
//  Created by Олег Адамов on 21.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import CoreLocation
import SceneKit


typealias ArtifactPosition = (x: Int32, y: Int32, z: Int32)

class BlockNode: CubeNode {
    let artifactId: ArtifactObjectIdentifier
    let objectId: BlockObjectIdentifier
    
    let size: Float
    
    var lat: Double
    var lon: Double
    var alt: Double
    
    var x: Int32
    var y: Int32
    var z: Int32
    
    
    init(block: Block, artifactId: ArtifactObjectIdentifier, blockSize: Float) {
        self.lat = block.latitude
        self.lon = block.longitude
        self.alt = block.altitude
        
        self.x = block.x
        self.y = block.y
        self.z = block.z
        
        self.size = blockSize
        
        self.artifactId = artifactId
        self.objectId = block.objectId
        
        let position = SCNVector3(size * Float(block.x), size * Float(block.y), size * Float(block.z))
        super.init(position: position, color: block.color)
    }
    
    
    func newPosition(from face: CubeFace) -> ArtifactPosition? {
        var x = self.x
        var y = self.y
        var z = self.z
        switch face {
            case .front:
                guard z < Int32.max else { return nil }
                z += 1
            case .back:
                guard z > Int32.min else { return nil }
                z -= 1
            case .left:
                guard x > Int32.min else { return nil }
                x -= 1
            case .right:
                guard x < Int32.max else { return nil }
                x += 1
            case .top:
                guard y < Int32.max else { return nil }
                y += 1
            case .bottom:
                guard y > Int32.min else { return nil }
                y -= 1
        }
        return (x, y, z)
    }
    
    
    func newLocation(for newPosition: ArtifactPosition) -> CLLocation {
        let d_lat = Double(newPosition.z - z) * Double(size)
        let d_lon = Double(newPosition.x - x) * Double(size)
        let d_alt = Double(newPosition.y - y) * Double(size)
        let translation = LocationTranslation(latitudeTranslation: d_lat, longitudeTranslation: d_lon, altitudeTranslation: d_alt)
        
        let coord2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let location = CLLocation(coordinate: coord2D, altitude: alt)
        
        return location.translatedLocation(with: translation)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
