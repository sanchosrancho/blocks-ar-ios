//
//  ARViewController.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit
import RealmSwift

class ARViewController: UIViewController {
    
    var sceneLocationView = ArtifactSceneView()
    var hudWindow: HUDWindow?
    let serialQueue = DispatchQueue(label: "com.envent.modify.serialSceneKitQueue")
    
    var artifactsToken: NotificationToken!
    var realm: Realm!
    var artifacts: Results<Artifact>?
    
    var artifactNodes = [ArtifactNode]()
    var zDistance: Float = -0.3
    var currentYPosition: Float = 0
    var placeState = PlaceState.preview {
        didSet { hudWindow?.hudController.placeState = self.placeState }
    }
    
    
    // MARK: - ViewController lifecycle
    
    deinit { artifactsToken.stop() }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupHUD()
        setupRealm()
        setupLocationAccuracyStatus()
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
    
    
    // MARK: - Setup
    
    func setupLocationAccuracyStatus() {
        self.hudWindow?.hudController.updateLocationStatus(Application.shared.state)
        
        NotificationCenter.default.addObserver(forName: .locationAccuracyChanged, object: nil, queue: nil) {
            guard let currentAccuracy = $0.userInfo?["current"] as? Application.LocationAccuracyState else { return }
            self.hudWindow?.hudController.updateLocationStatus(currentAccuracy)
            
            if case Application.LocationAccuracyState.good = currentAccuracy {
                self.sceneLocationView.shouldUpdateLocationEstimate = false
                self.setupRealmResults()
            }
        }
    }
    
    func setupScene() {
        sceneLocationView.showsStatistics = false
        sceneLocationView.run()
//        sceneLocationView.scene.enableEnvironmentMapWithIntensity(1000, queue: serialQueue)
        sceneLocationView.antialiasingMode = .multisampling4X
        sceneLocationView.automaticallyUpdatesLighting = true
        sceneLocationView.autoenablesDefaultLighting = true
        
        sceneLocationView.preferredFramesPerSecond = 60
        if let camera = sceneLocationView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.maximumExposure = 3
        }
        sceneLocationView.session.delegate = self
        sceneLocationView.locationDelegate = self
        view.addSubview(sceneLocationView)
    }
    
    func setupHUD() {
        hudWindow = HUDWindow(frame: view.bounds)
        hudWindow?.hudController.delegate = self
        hudWindow?.makeKeyAndVisible()
    }
    
    func setupRealm() {
        self.realm = Database.realmMain
        
        self.artifacts = realm.objects(Artifact.self)
        self.artifactsToken = artifacts?.addNotificationBlock { changes in
            DispatchQueue.main.async { [weak self] in
                switch changes {
                case .initial:
                    self?.loadAllArtifacts()
                case .update(_, let deletions, let insertions, let modifications):
                    self?.deleteArtifacts(indexes: deletions)
                    self?.insertArtifacts(indexes: insertions)
                    self?.updateArtifacts(indexes: modifications)
                case .error(let error):
                    print("Updating artifacts error: \(error)")
                }
            }
        }
    }
    
}
