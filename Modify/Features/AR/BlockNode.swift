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
    let artifactId: String
    let blockId: String
    
    var lat: Double
    var lon: Double
    var alt: Double
    
    var x: Int32
    var y: Int32
    var z: Int32
    
    
    init(block: Block, artifactId: String) {
        self.lat = block.latitude
        self.lon = block.longitude
        self.alt = block.altitude
        
        self.x = block.x
        self.y = block.y
        self.z = block.z
        
        self.artifactId = artifactId
        self.blockId = block.objectId
        
        let size = BlockNode.size
        let position = SCNVector3(size * CGFloat(block.x), size * CGFloat(block.y), size * CGFloat(block.z))
        super.init(position: position, color: block.color)
    }
    
    
    func newPosition(from face: CubeFace) -> ArtifactPosition {
        var x = self.x
        var y = self.y
        var z = self.z
        switch face {
            case .front:  z += 1
            case .back:   z -= 1
            case .left:   x -= 1
            case .right:  x += 1
            case .top:    y += 1
            case .bottom: y -= 1
        }
        return (x, y, z)
    }
    
    
    func newLocation(for newPosition: ArtifactPosition) -> CLLocation {
        let d_lat = Double(newPosition.z - z) * Double(CubeNode.size)
        let d_lon = Double(newPosition.x - x) * Double(CubeNode.size)
        let d_alt = Double(newPosition.y - y) * Double(CubeNode.size)
        let translation = LocationTranslation(latitudeTranslation: d_lat, longitudeTranslation: d_lon, altitudeTranslation: d_alt)
        
        let coord2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let location = CLLocation(coordinate: coord2D, altitude: alt)
        
        return location.translatedLocation(with: translation)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}