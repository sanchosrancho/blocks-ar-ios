//
//  MapViewController+MapCircles.swift
//  Modify
//
//  Created by Олег Адамов on 12.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import MapKit


extension MapViewController {
    
    func reloadCircles() {
        guard let results = self.results else { return }
        guard let mapView = self.mapView else { return }
        print("Will reload overlays, count: \(results.count)")
        mapView.removeOverlays(mapView.overlays)
        
        for artifact in results {
            let mapCircle = MapCircle(center: artifact.locationCoordinate2D, radius: artifact.radius, objectId: artifact.objectId)
            mapView.add(mapCircle)
        }
    }
    
    
    func deleteCircles(indexes: [Int]) {
        guard let mapView = self.mapView else { return }
        print("Will delete at indexes: \(indexes)")
        for index in indexes {
            guard index < mapView.overlays.count else { continue }
            mapView.remove(mapView.overlays[index])
        }
    }
    
    
    func insertCircles(indexes: [Int]) {
        guard let results = self.results else { return }
        guard let mapView = self.mapView else { return }
        print("Will insert at indexes: \(indexes)")
        for index in indexes {
            guard index < results.count else { continue }
            let artifact = results[index]
            let mapCircle = MapCircle(center: artifact.locationCoordinate2D, radius: artifact.radius, objectId: artifact.objectId)
            
            if index < mapView.overlays.count {
                mapView.insert(mapCircle, at: index)
            } else {
                mapView.add(mapCircle)
            }
        }
    }
    
    
    func updateCircles(indexes: [Int]) {
        guard let results = self.results else { return }
        guard let mapView = self.mapView else { return }
        print("Will update at indexes: \(indexes)")
        for index in indexes {
            guard index < results.count, index < mapView.overlays.count else { continue }
            guard let overlay = mapView.overlays[index] as? MapCircle else { continue }
            let artifact = results[index]
            
            guard CLLocationDistance(artifact.radius) != overlay.radius else { continue }
            
            let mapCircle = MapCircle(center: artifact.locationCoordinate2D, radius: artifact.radius, objectId: artifact.objectId)
            mapView.exchangeOverlay(overlay, with: mapCircle)
        }
    }
    
}
