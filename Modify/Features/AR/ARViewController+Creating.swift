//
//  ARViewController+Creating.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

enum PlaceState {
    case preview
    case placing(CubeGroundable)
    case editing(ArtifactNode)
}

extension ARViewController {
    
    func addInitialCubeToCamera(with color: UIColor) {
        let cubeNode = CubeNode(position: SCNVector3(0, 0, zDistance), color: color)
        sceneLocationView.pointOfView?.addChildNode(cubeNode)
//        sceneLocationView.scene.rootNode.addChildNode(cubeNode)
        let placeableCube = CubeGroundable(cubeNode)
        self.placeState = PlaceState.placing(placeableCube)
    }
    
    
    func saveArtifact(cubeNode: CubeNode) {
        guard let location = sceneLocationView.currentLocation(),
              let position = sceneLocationView.currentScenePosition() else { return }
        
        let locationEstimate = SceneLocationEstimate(location: location, position: position)
        let artifactLocation = locationEstimate.translatedLocation(to: cubeNode.position)
        
        print("Creating artifact with location: (\(artifactLocation.coordinate.latitude), \(artifactLocation.coordinate.longitude), \(artifactLocation.altitude))")
        
        let onCreateModelBlock = { [weak self] (artifactObjectId: ArtifactObjectIdentifier) -> Void in
            self?.creatingArtifactObjectId = artifactObjectId
            guard let artifactNodes = self?.artifactNodes else { return }
            for artifactNode in artifactNodes {
                guard artifactNode.artifactId == artifactObjectId else { continue }
                self?.placeState = .editing(artifactNode)
                self?.creatingArtifactObjectId = nil
                break
            }
        }
        
        Artifacts.create(location: artifactLocation,
                eulerX: cubeNode.eulerAngles.x,
                eulerY: cubeNode.eulerAngles.y,
                eulerZ: cubeNode.eulerAngles.z,
                distanceToGround: CLLocationDistance(cubeNode.position.y),
                color: cubeNode.hexColor,
                size: CubeNode.size,
                onCreateModel: onCreateModelBlock)
            .then {
                print("Artifact was added")
            }.catch { error in
                print("Artifact couldn't be added because some error occured: ", error)
            }
        
    }
    
    
    func addBlock(with location: CLLocation, toArtifact artifactId: ArtifactObjectIdentifier, color: UIColor, position: ArtifactPosition) {
        Blocks.create(artifactId: artifactId, location: location, color: color, position: position)
            .then {
                print("Block was added")
            }.catch { error in
                print("Block couldn't be added because some error occured: ", error)
            }
    }
    
    
    func deleteBlock(with blockId: BlockObjectIdentifier, latitude: Double, longitude: Double) {
        Blocks.delete(id: blockId)
            .then {
                print("Block was deleted")
            }.catch { error in
                print("Block couldn't be deleted because some error occured: ", error)
            }
    }
}
