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
    
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneLocationView.scene.rootNode.addChildNode(scene.rootNode.childNode(withName: "ship", recursively: true)!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
