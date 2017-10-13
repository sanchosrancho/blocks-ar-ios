//
//  MapViewController+UIControls.swift
//  Modify
//
//  Created by Олег Адамов on 13.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import MapKit


extension MapViewController {
    
    func setupMapView() {
        let mapView = ScalableMapView(frame: UIScreen.main.bounds)
        self.view.addSubview(mapView)
        self.mapView = mapView
        
        if let location = Application.shared.currentLocation {
            let initialSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            mapView.centerMap(on: location.coordinate, animated: false, span: initialSpan)
        }
        
        mapView.delegate = self
        updateResults()
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
            self.mapView?.centerMap(on: location.coordinate, animated: true, span: nil)
        }
    }
}


// test
extension MapViewController {
    
    func addLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target:self , action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 1.0
        mapView?.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        guard let mapView = self.mapView else { return }
        
        let point = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        let location = CLLocation(coordinate: coordinate, altitude: 1)
        let onCreateModelBlock = { (artifactObjectId: ArtifactObjectIdentifier) -> Void in
        }
        Artifacts.create(location: location, eulerX: 0, eulerY: 0, eulerZ: 0, distanceToGround: 0, color: UIColor.red.hexString(), size: CubeNode.size, onCreateModel: onCreateModelBlock)
            .then {
                print("Artifact was added")
            }.catch { error in
                print("Artifact couldn't be added because some error occured: ", error)
        }
    }
}
