//
//  ViewController.swift
//  Modify
//
//  Created by Alex Shevlyakov on 22.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ARCL
import CoreLocation
import RealmSwift

open class ArtifactSceneView: SceneLocationView {
    public var locationNodes = [LocationNode]()
}


class ViewController: UIViewController, ARSCNViewDelegate {
    
    var hudWindow: HUDWindow?
    var sceneLocationView = ArtifactSceneView()
    
    deinit { notificationToken.stop() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showsStatistics = true
        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        prepareHUD()
        
        /*
        let pinCoordinate = CLLocationCoordinate2D(latitude: 59.934891129, longitude: 30.324988654)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: CLLocationDistance(0))
        let pinLocationNode = LocationNode(location: pinLocation)
//        pinLocationNode.scaleRelativeToDistance = $0.scale
        
        let scene = SCNScene(named: "art.scnassets/mr.pig.scn")!
        let object = scene.rootNode.childNode(withName: "pig", recursively: true)!
        pinLocationNode.addChildNode(object)
//        pinLocationNode.continuallyAdjustNodePositionWhenWithinRange
        
        setupRealm()
    }
    
    func prepareHUD() {
        hudWindow = HUDWindow(frame: view.bounds)
        hudWindow?.hudController.delegate = self
        hudWindow?.makeKeyAndVisible()
    }
    
    func addArtifact() {
        guard let realm = self.results?.realm else { print("no realm to add"); return }
        
        let currentLocation = sceneLocationView.currentLocation()
        try! realm.write {
            let artifact = Artifact()
            artifact.lat = currentLocation?.coordinate.latitude ?? 0
            artifact.lon = currentLocation?.coordinate.longitude ?? 0
            artifact.alt = currentLocation?.altitude ?? 0
            realm.add(artifact)
        }
//        let scene = SCNScene(named: "art.scnassets/mr.pig.scn")!
//        let object = scene.rootNode.childNode(withName: "pig", recursively: true)!
//        object.scale = SCNVector3(0.02, 0.02, 0.02)
//        object.position = sceneLocationView.currentScenePosition()!
//        sceneLocationView.scene.rootNode.addChildNode(object)
    }
    
    
    func setupRealm() {
        SyncUser.logIn(with: .usernamePassword(username: "sanchosrancho@gmail.com", password: "(Zotto123123)"), server: URL(string: "http://212.224.112.252:9080")!) { user, error in
            guard let user = user else { fatalError(String(describing: error)) }
            
            DispatchQueue.main.async {
                // Open Realm
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://212.224.112.252:9080/~/artifacts")!)
                )
                self.realm = try! Realm(configuration: configuration)
                
                // Show initial tasks
                func updateList() {
                    if self.results?.realm == nil {
                        self.results = self.realm.objects(Artifact.self)
                    }
                    self.removeOldArtifacts()
                    self.placeArtifacts()
                }
                updateList()
                
                // Notify us when Realm changes
                self.notificationToken = self.realm.addNotificationBlock { _, _  in
                    print("update results")
                    updateList()
                }
            }
        }
    }
    
    
    func removeOldArtifacts() {
        sceneLocationView.locationNodes.forEach {
            sceneLocationView.removeLocationNode(locationNode: $0)
        }
    }
    
    
    func placeArtifacts() {
        print("artifacts: \(self.results?.count ?? 0)")
        
        guard let results = self.results else { return }
        for artifact in results {
            let coord = CLLocationCoordinate2D(latitude: artifact.lat, longitude: artifact.lon)
            let location = CLLocation(coordinate: coord, altitude: artifact.alt)
            let locationNode = LocationNode(location: location)
            
            let scene = SCNScene(named: "art.scnassets/mr.pig.scn")!
            let object = scene.rootNode.childNode(withName: "pig", recursively: true)!
            object.scale = SCNVector3(0.1, 0.1, 0.1)
            locationNode.addChildNode(object)
            
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
        hudWindow?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
}


extension ViewController: HUDViewControllerDelegate {
    
    func hudAddObjectPressed() {
        addArtifact()
    }
    
    
    
    func hudStopAdjustingNodesPosition() {
        sceneLocationView.locationNodes.forEach {
            $0.continuallyUpdatePositionAndScale = false
        }
    }
    func hudStartAdjustingNodesPosition() {
        sceneLocationView.locationNodes.forEach {
            $0.continuallyUpdatePositionAndScale = true
        }
    }
}
