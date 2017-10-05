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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupCloseButton()
        setupCurrentLocationButton()
    }

    
    func setupMapView() {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        
        self.view.addSubview(mapView)
        self.mapView = mapView
        
        if let location = Application.shared.currentLocation {
            let initialSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            centerMap(on: location, animated: false, span: initialSpan)
        }
    }
    
    
    func centerMap(on location: CLLocation, animated: Bool = true, span: MKCoordinateSpan? = nil) {
        guard let spanValue = span ?? mapView?.region.span else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, span: spanValue)
        mapView?.setRegion(region, animated: animated)
    }
    
    
    func setupCloseButton() {
        let size: CGFloat = 46
        let frame = CGRect(x: 16, y: 36, width: size, height: size)
        let button = UIButton(frame: frame)
        button.layer.cornerRadius = size/2
        button.setImage(UIImage(named: "btn_close"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .innerGray
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setupCurrentLocationButton() {
        let size: CGFloat = 46
        let frame = CGRect(x: UIScreen.main.bounds.width - size - 16, y: 36, width: size, height: size)
        let button = UIButton(frame: frame)
        button.layer.cornerRadius = size/2
        button.setImage(UIImage(named: "btn_location"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .innerGray
        button.addTarget(self, action: #selector(currentLocationButtonPressed), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func currentLocationButtonPressed() {
        if let location = Application.shared.currentLocation {
            centerMap(on: location)
        }
    }
}
