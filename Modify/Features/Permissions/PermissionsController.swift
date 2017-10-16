//
//  PermissionsController.swift
//  Modify
//
//  Created by Олег Адамов on 16.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import UIKit


protocol PermissionViewProtocol: class {
    // var permissionType: PermissionType { get }
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
}
