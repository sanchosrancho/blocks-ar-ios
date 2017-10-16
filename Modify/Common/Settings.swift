//
//  Settings.swift
//  Modify
//
//  Created by Олег Адамов on 16.10.2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation


struct Settings {
    
    
    static var needRequestPermissions: Bool {
        return !UserDefaults.standard.bool(forKey: alreadyAskedPermissionKey)
    }
    
    static func permissionsRequested() {
        UserDefaults.standard.set(true, forKey: alreadyAskedPermissionKey)
    }
    
    
    //MARK: - Private
    
    private static let alreadyAskedPermissionKey = "alreadyAskedPermissionKey"
}
