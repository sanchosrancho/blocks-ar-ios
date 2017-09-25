//
//  HUDWindow.swift
//  Modify
//
//  Created by Олег Адамов on 25.09.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit


// class HUDButton: UIButton {}

class HUDWindow: UIWindow {

    var hudController: HUDViewController {
        return self.rootViewController as! HUDViewController
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rootViewController = HUDViewController()
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
     guard let hitView = super.hitTest(point, with: event) else { return nil }
     if hitView is HUDButton { return hitView }
     return nil
     }*/

}
