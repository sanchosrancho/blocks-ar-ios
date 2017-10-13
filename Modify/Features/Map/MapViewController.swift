//
//  MapViewController.swift
//  Modify
//
//  Created by Олег Адамов on 04.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import MapKit
import RealmSwift


class MapViewController: UIViewController {

    var mapView: ScalableMapView?
    var results: Results<Artifact>?
    var token: NotificationToken?
    var fetchTimer: Timer?
    
    
    deinit { token?.stop() }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupCloseButton()
        setupCurrentLocationButton()
        // test
        addLongPressGesture()
        //
    }
    
    
    @objc func updateResults() {
        print("update results!")
        let leftBottom = mapView!.swCoordinate
        let rightTop = mapView!.neCoordinate
        
        self.results = Artifacts.objects(from: leftBottom, to: rightTop)
        self.token = self.results?.addNotificationBlock { [weak self] changes in
            switch changes {
            case .initial:
                self?.reloadCircles()
            case .update(_, let deletions, let insertions, let modifications):
                self?.deleteCircles(indexes: deletions)
                self?.insertCircles(indexes: insertions)
                self?.updateCircles(indexes: modifications)
            case .error(let error):
                print("Realm notification block error: \(error)")
            }
        }
        
        Artifacts.getByBounds(from: leftBottom, to: rightTop, withBlocks: false).then { _ -> Void in
        }.catch {
            print("Loading artifacts for map error: \($0)")
        }
    }
    
    
    //MARK: Timer
    
    func restartTimer() {
        fetchTimer?.invalidate()
        fetchTimer = nil
        fetchTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateResults), userInfo: nil, repeats: false)
    }
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleOverlay = overlay as! MapCircle
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.fillColor = .mapArtifact
        circleRenderer.alpha = 0.4
        return circleRenderer
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.mapView!.zoomLevel < self.mapView!.minZoom {
            self.mapView!.zoomLevel = self.mapView!.minZoom
        }
        else {
            restartTimer()
        }
    }
}
