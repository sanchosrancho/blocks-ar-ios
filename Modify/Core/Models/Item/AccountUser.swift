//
//  AccountUser.swift
//  Modify
//
//  Created by Alex Shevlyakov on 21/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Locksmith
import CoreLocation
import RealmSwift

struct AccountUser {
    let platform = "ios"
    let locale = NSLocale.current.languageCode
    let deviceToken = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    var userId:    UserObjectIdentifier? { didSet { updateStore() } }
    var pushToken: String? { didSet { updateStore() } }
    var token:     String? {
        didSet {
            updateStore()
            Api.shared.token = self.token
        }
    }
    
    var latitude:  CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var position: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var user: User? {
        guard let id = userId, id != "" else { return nil }
        
        let realm = Database.realmMain
        return Users.find(id: id, realm: realm)
    }
    
    init() {
        self.readFromStore()
    }
}

extension AccountUser: GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
    func updateStore() {
        do {
            try self.createInSecureStore()
        } catch (let error) {
            print(error)
        }
    }
    
    mutating func readFromStore() {
        guard let stored = self.readFromSecureStore()?.data else { return }
        self.userId    = stored["userId"]    as? UserObjectIdentifier
        self.pushToken = stored["pushToken"] as? String
        self.token     = stored["token"]     as? String
    }
    
    var service: String { return "Modify" }
    var account: String { return deviceToken }
    var data: [String: Any] {
        return [
            "userId":    userId    ?? "",
            "pushToken": pushToken ?? "",
            "token":     token     ?? ""
        ]
    }
}
