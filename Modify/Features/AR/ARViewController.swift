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
    var notificationToken: NotificationToken!
    var realm: Realm!
    var results: Results<Artifact>?
    var zDistance: Float = 2
    
    internal var placeState = PlaceState.none {
        didSet {
            var isPlacing = false
            if case .placing(_) = placeState { isPlacing = true }
            hudWindow?.hudController.updateState(isPlacing: isPlacing)
        }
    }
    
    
    // MARK: - ViewController lifecycle
    
    deinit { notificationToken.stop() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupHUD()
        setupRealm()
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
    
    func setupScene() {
        sceneLocationView.showsStatistics = true
        sceneLocationView.run()
        sceneLocationView.scene.enableEnvironmentMapWithIntensity(500, queue: serialQueue)
        sceneLocationView.antialiasingMode = .multisampling4X
        sceneLocationView.automaticallyUpdatesLighting = false
        
        sceneLocationView.preferredFramesPerSecond = 60
//        sceneLocationView.contentScaleFactor = 1.3
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
        SyncUser.logIn(with: .usernamePassword(username: "sanchosrancho@gmail.com", password: "(Zotto123123)"), server: URL(string: "http://212.224.112.252:9080")!) { user, error in
            guard let user = user else { print(error ?? "Unknown sync error"); return }
            
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
    
}
