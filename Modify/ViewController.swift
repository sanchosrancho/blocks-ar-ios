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


enum PlaceState {
    case none
    case placing(SCNNode)
}

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var hudWindow: HUDWindow?
    var sceneLocationView = ArtifactSceneView()
    var notificationToken: NotificationToken!
    var realm: Realm!
    var results: Results<Artifact>?
    
    private var placeState = PlaceState.none {
        didSet {
            var isPlacing = false
            if case .placing(_) = placeState { isPlacing = true }
            hudWindow?.hudController.updateState(isPlacing: isPlacing)
        }
    }
    
    
    deinit { notificationToken.stop() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showsStatistics = true
        sceneLocationView.run()
        sceneLocationView.session.delegate = self
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
        let scene = SCNScene(named: "art.scnassets/mr.pig.scn")!
        let object = scene.rootNode.childNode(withName: "pig", recursively: true)!
        object.scale = SCNVector3(0.1, 0.1, 0.1)
        object.position = SCNVector3(0, 0, -2)
        object.opacity = 0.8
        sceneLocationView.pointOfView?.addChildNode(object)
        self.placeState = PlaceState.placing(object)
        
//        let ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.childNode(withName: "ship", recursively: true)!
//        ship.position = SCNVector3(0, 0, -2)
//        sceneLocationView.pointOfView?.addChildNode(ship)
//        self.placeState = PlaceState.placing(ship)
    }
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if case .placing(let node) = placeState {
            node.eulerAngles.x = -frame.camera.eulerAngles.x
            node.eulerAngles.z = -frame.camera.eulerAngles.z - Float(Double.pi / 2)
        }
    }
    
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            self.hudWindow?.hudController.cameraReady(true)
        default:
            self.hudWindow?.hudController.cameraReady(false)
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
    
    func saveArtifact(withPosition artifactPosition: SCNVector3) {
        guard
            let currentLocation = sceneLocationView.currentLocation(),
            let currentPosition = sceneLocationView.currentScenePosition()
        else {
            return
        }
        
        let currentLocationEstimate = SceneLocationEstimate(location: currentLocation, position: currentPosition)
        let artifactLocation = currentLocationEstimate.translatedLocation(to: artifactPosition)
        let distanceToGround = artifactPosition.y
        
        try! realm.write {
            let artifact = Artifact()
            artifact.lat = artifactLocation.coordinate.latitude
            artifact.lon = artifactLocation.coordinate.longitude
            artifact.alt = artifactLocation.altitude
            artifact.horizontalAccuracy = artifactLocation.horizontalAccuracy
            artifact.verticalAccuracy = artifactLocation.verticalAccuracy
            artifact.groundDistance = CLLocationDistance(distanceToGround)
            artifact.createdAt = NSDate()
            realm.add(artifact)
        }
    }
}


extension ViewController: HUDViewControllerDelegate {
    
    func hudAddObjectPressed() {
        addArtifact()
    }
    
    func hudPlaceObjectPressed() {
        if case .placing(let node) = placeState {
            let t = node.worldTransform
            node.removeFromParentNode()
            node.transform = t
            self.saveArtifact(withPosition: node.position)
            placeState = .none
        }
    }
    
    func hudPlaceObjectCancelled() {
        if case .placing(let node) = placeState {
            node.removeFromParentNode()
            placeState = .none
        }
    }

    func hudStopAdjustingNodesPosition() {
        sceneLocationView.locationManager.locationManager?.stopUpdatingLocation()
        sceneLocationView.locationManager.locationManager?.stopUpdatingHeading()
//        sceneLocationView.locationNodes.forEach {
//            $0.continuallyUpdatePositionAndScale = false
//        }
    }
    
    func hudStartAdjustingNodesPosition() {
        sceneLocationView.locationManager.locationManager?.startUpdatingLocation()
        sceneLocationView.locationManager.locationManager?.startUpdatingHeading()
//        sceneLocationView.locationNodes.forEach {
//            $0.continuallyUpdatePositionAndScale = true
//        }
    }
}
