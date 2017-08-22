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
    
    let addObjectButton = UIButton(frame: CGRect(x: 20, y: 20, width: 200, height: 100))
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showsStatistics = true
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneLocationView.scene.rootNode.addChildNode(scene.rootNode.childNode(withName: "ship", recursively: true)!)
        
        addObjectButton.setTitle("Add object", for: .normal)
        addObjectButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addObjectButton.addTarget(self, action: #selector(ViewController.addObject), for: .touchUpInside)
        view.addSubview(addObjectButton)
    }
    
    @objc func addObject() {
        let object = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.childNode(withName: "ship", recursively: true)!
        object.position = sceneLocationView.currentScenePosition()!
        sceneLocationView.scene.rootNode.addChildNode(object)
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
