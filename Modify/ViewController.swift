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


class ViewController: UIViewController, ARSCNViewDelegate {
    
    var hudWindow: HUDWindow?
    var sceneLocationView = SceneLocationView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showsStatistics = true
        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        prepareHUD()
    }
    
    func prepareHUD() {
        hudWindow = HUDWindow(frame: view.bounds)
        hudWindow?.hudController.delegate = self
        hudWindow?.makeKeyAndVisible()
    }
    
    func addObject() {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let object = scene.rootNode.childNode(withName: "ship", recursively: true)!
        object.position = sceneLocationView.currentScenePosition()!
        sceneLocationView.scene.rootNode.addChildNode(object)
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
        addObject()
    }
}
