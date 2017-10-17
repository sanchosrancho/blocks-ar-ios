//
//  PermissionsController.swift
//  Modify
//
//  Created by Олег Адамов on 16.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit


protocol PermissionViewProtocol: class {
    func actionButtonPressed(with type: PermissionType)
}


enum PermissionType {
    case camera
    case location
    case accuracy
}


class PermissionsController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //self.modalPresentationStyle = .overCurrentContext
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        setupContainer()
        setupScreens()
    }

    
    //MARK: - Private
    
    var container: UIScrollView?
    var permissionTypes: [PermissionType] = [.camera, .location, .accuracy]
    
    
    func setupContainer() {
        let screenSize = UIScreen.main.bounds.size
        let frame = CGRect(x: 0, y: 0, width: 3 * screenSize.width, height: screenSize.height)
        let view = UIScrollView(frame: frame)
        self.view.addSubview(view)
        self.container = view
    }
    
    
    func setupScreens() {
        let width = self.view.bounds.width
        for i in 0..<permissionTypes.count - 1 {
            let frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: self.view.bounds.height)
            let view = PermissionsPrivacyView(frame: frame, type: permissionTypes[i])
            view.delegate = self
            container?.addSubview(view)
        }
    }
}


extension PermissionsController: PermissionViewProtocol {
    
    func actionButtonPressed(with type: PermissionType) {
    }
}
