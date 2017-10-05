//
//  MapViewController.swift
//  Modify
//
//  Created by Олег Адамов on 04.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import MapKit


class MapViewController: UIViewController {

    var mapView: MKMapView?
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLocation(_:)), name: .locationUpdated, object: nil)
    }
    
    
    @objc
    private func handleUpdateLocation(_ notification: Notification) {
        print("!!")
    }

    
    private func setupMapView() {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        self.view.addSubview(mapView)
        self.mapView = mapView
    }
}
