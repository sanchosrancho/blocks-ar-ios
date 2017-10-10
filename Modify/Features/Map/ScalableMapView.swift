//
//  ScalableMapView.swift
//  Modify
//
//  Created by Олег Адамов on 10.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import MapKit

class ScalableMapView: MKMapView {

    let minZoom: Float = 4.5
    
    var zoomLevel: Float {
        get {
            return Float(log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1);
        }
        set {
            centerMap(on: self.centerCoordinate, zoomLevel: newValue, animated: true)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsUserLocation = true
    }
    
    
    func centerMap(on coordinate: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool){
        let span = MKCoordinateSpanMake(0, 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256)
        centerMap(on: coordinate, animated: animated, span: span)
    }
    
    
    func centerMap(on coordinate: CLLocationCoordinate2D, animated: Bool, span: MKCoordinateSpan?) {
        let spanValue = span ?? self.region.span
        let region = MKCoordinateRegion(center: coordinate, span: spanValue)
        self.setRegion(region, animated: animated)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MKMapView {
    
    var swCoordinate: CLLocationCoordinate2D {
        let point = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        return self.convert(point, toCoordinateFrom: self)
    }
    
    var neCoordinate: CLLocationCoordinate2D {
        let point = CGPoint(x: self.bounds.maxX, y: self.bounds.minY)
        return self.convert(point, toCoordinateFrom: self)
    }
}
