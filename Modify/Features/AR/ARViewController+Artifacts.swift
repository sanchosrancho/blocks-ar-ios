//
//  ARViewController+Artifacts.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

extension ARViewController {
    
    func updateArtifacts() {
        guard let results = self.results else { return }
        
        let actual = Set( results.map { $0.objectId } )
        print("Location nodes: ", sceneLocationView.locationNodes)
        let onScene = Set( sceneLocationView.locationNodes.map { ($0 as! ArtifactLocationNode).artifactId } )
        
        var shouldBeRemoved = Set(onScene)
        shouldBeRemoved.subtract(actual)
        
        var shouldBeAdded = Set(actual)
        shouldBeAdded.subtract(onScene)
        
        print("\(shouldBeRemoved.count) artifacts should be removed")
        print("\(shouldBeAdded.count) artifacts should be added")
        print("\(results.count) artifacts should be placed on scene")
        
        shouldBeRemoved.forEach {
            guard let node = sceneLocationView.findNode(byId: $0) else { return }
            sceneLocationView.removeLocationNode(locationNode: node)
        }
        
        for artifact in results {
            guard shouldBeAdded.contains(artifact.objectId) else { continue }
            placeArtifact(artifact)
        }
    }
    
    func placeArtifact(_ artifact: Artifact) {
        guard
            let currentLocation = sceneLocationView.currentLocation(),
            let currentPosition = sceneLocationView.currentScenePosition()
            else {
                return
        }
        
        let altitude = currentLocation.altitude - Double(currentPosition.y) + artifact.groundDistance
        let coord = CLLocationCoordinate2D(latitude: artifact.lat, longitude: artifact.lon)
        let location = CLLocation(coordinate: coord, altitude: altitude)
        
        guard let locationNode = ArtifactLocationNode(artifact: artifact, location: location) else { return }
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
    }
    
}