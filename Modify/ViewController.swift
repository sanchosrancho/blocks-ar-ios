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
import CoreLocation
import RealmSwift

class ArtifactSceneView: SceneLocationView {
    
    public func findNode(byId id: String) -> ArtifactNode? {
        for node in self.locationNodes {
            guard let artifactNode = node as? ArtifactNode else { continue }
            if artifactNode.artifactId == id {
                return artifactNode
            }
        }
        return nil
    }
}

class ArtifactNode: LocationNode {
    let artifactId: String
    
    public init(location: CLLocation?, artifactId: String) {
        self.artifactId = artifactId
        super.init(location: location)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var hudWindow: HUDWindow?
    var sceneLocationView = ArtifactSceneView()
    var notificationToken: NotificationToken!
    var realm: Realm!
    var results: Results<Artifact>?
    
    deinit { notificationToken.stop() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showsStatistics = true
        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        prepareHUD()
        setupRealm()
    }
    
    func prepareHUD() {
        hudWindow = HUDWindow(frame: view.bounds)
        hudWindow?.hudController.delegate = self
        hudWindow?.makeKeyAndVisible()
    }
    
    func addArtifact() {
        let currentLocation = sceneLocationView.currentLocation()
        try! realm.write {
            let artifact = Artifact()
            artifact.lat = currentLocation?.coordinate.latitude ?? 0
            artifact.lon = currentLocation?.coordinate.longitude ?? 0
            artifact.alt = currentLocation?.altitude ?? 0
            artifact.horizontalAccuracy = currentLocation?.horizontalAccuracy ?? -2
            artifact.verticalAccuracy = currentLocation?.verticalAccuracy ?? -2
            artifact.groundDistance = CLLocationDistance( sceneLocationView.currentScenePosition()?.y ?? -100 )
            artifact.createdAt = NSDate()
            realm.add(artifact)
        }
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
                
                // Show initial artifacts
                func updateList() {
                    if self.results?.realm == nil {
                        self.results = self.realm.objects(Artifact.self)
                    }
                    self.updateArtifacts()
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
    
    func updateArtifacts() {
        guard let results = self.results else { return }
        
        let actual = Set( results.map { $0.objectId } )
        print("Location nodes: ", sceneLocationView.locationNodes)
        let onScene = Set( sceneLocationView.locationNodes.map { ($0 as! ArtifactNode).artifactId } )
        
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
        let location = CLLocation(coordinate: coord, altitude: altitude) // artifact.alt
        let locationNode = ArtifactNode(location: location, artifactId: artifact.objectId)
        
        let scene = SCNScene(named: "art.scnassets/mr.pig.scn")!
        let object = scene.rootNode.childNode(withName: "pig", recursively: true)!
        object.scale = SCNVector3(0.1, 0.1, 0.1)
        locationNode.addChildNode(object)
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
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
