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
        NotificationCenter.default.removeObserver(self, name: .locationUpdated, object: nil)
        print("deinit")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLocation(_:)), name: .locationUpdated, object: nil)
        
//        NotificationCenter.default.addObserver(forName: .locationUpdated, object: nil, queue: nil) { [weak self] notification in
//            guard let location = notification.object as? CLLocation else { return }
//            print("!")
//        }
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
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
