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
    
    private var placeState = PlaceState.none
    private var placeNode: SCNNode?
    
    
    deinit { notificationToken.stop() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showsStatistics = true
        sceneLocationView.run()
        sceneLocationView.session.delegate = self
        view.addSubview(sceneLocationView)
        
        prepareHUD()
//        setupRealm()
    }
    
    
    func prepareHUD() {
        hudWindow = HUDWindow(frame: view.bounds)
        hudWindow?.hudController.delegate = self
        hudWindow?.makeKeyAndVisible()
    }
    
    
    func addArtifact() {
        let ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.childNode(withName: "ship", recursively: true)!
        ship.position = SCNVector3(0, 0, -2)
        sceneLocationView.pointOfView?.addChildNode(ship)
        self.placeNode = ship
    }
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let ship = placeNode else { return }
        ship.eulerAngles.x = -frame.camera.eulerAngles.x
        ship.eulerAngles.z = -frame.camera.eulerAngles.z - Float(Double.pi / 2)
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
        let coord = CLLocationCoordinate2D(latitude: artifact.lat, longitude: artifact.lon)
        let location = CLLocation(coordinate: coord, altitude: artifact.alt)
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

extension float4x4 {
    /// Treats matrix as a (right-hand column-major convention) transform matrix
    /// and factors out the translation component of the transform.
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
