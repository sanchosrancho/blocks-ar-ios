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
    
    var userId:    String? { didSet { try? self.createInSecureStore() } }
    var pushToken: String? { didSet { try? self.createInSecureStore() } }
    var token:     String? { didSet { try? self.createInSecureStore() } }
    
    var latitude:  CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var position: CLLocationCoordinate2D? {
        get {
            guard let lat = latitude, let lon = longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
//            didSet { try? self.createInSecureStore() }
    }
    
    var user: User? {
        guard userId != "" else { return nil }
        let realm = try! Realm()
        return realm.object(ofType: User.self, forPrimaryKey: userId)
    }
    
    init() {
        self.readFromStore()
    }
}

extension AccountUser: GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
    mutating func readFromStore() {
        guard let stored = self.readFromSecureStore()?.data else { return }
        self.userId    = stored["userId"]    as? String
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
