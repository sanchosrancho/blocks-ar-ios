//
//  Account.swift
//  Modify
//
//  Created by Alex Shevlyakov on 12/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit
import Moya
import Locksmith
import CoreLocation

public final class Account {
    
    struct Info {
        let platform = "ios"
        let locale = NSLocale.current.languageCode
        let deviceToken = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        var userId: String?    { didSet { try? self.createInSecureStore() } }
        var pushToken: String? { didSet { try? self.createInSecureStore() } }
        var token: String?     { didSet { try? self.createInSecureStore() } }
        
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
    
    
    lazy var info = Info()
    
    private static let _shared = Account()
    public static var shared: Account {
        return _shared
    }
    
    var accessToken: String? {
        get { return self.info.token }
        set {
            self.info.token = newValue
            // syncPushToken()
        }
    }
    var pushToken: String? {
        get { return self.info.pushToken }
        set {
            self.info.pushToken = newValue
            // syncPushToken()
        }
    }
    
    func login() -> Promise<Void> {
        return firstly {
                fetchToken()
            }.then { token -> Void in
                self.info.token = token
            }
    }
    
    func fetchToken() -> Promise<String> {
        let api = MoyaProvider<Api.User>(plugins: [NetworkLoggerPlugin()])
        return firstly {
                api.request(target: .login(deviceId: self.info.deviceToken))
            }.then { (response: Moya.Response) -> Api.User.Response in
                try JSONDecoder().decode(Api.User.Response.self, from: response.data)
            }.then { (json: Api.User.Response) -> String in
                json.result.token
            }
    }
    
    func syncUserInfo() -> Promise<Void> {
        return firstly {
                guard let token = self.info.token else { throw NSError.cancelledError() }
                let authPlugin = AccessTokenPlugin(tokenClosure: token)
                let api = MoyaProvider<Api.User>(plugins: [authPlugin, NetworkLoggerPlugin()])
            
                return api.request(target: .update(
                    locale:    self.info.locale,
                    pushToken: self.info.platform,
                    platform:  self.info.platform,
                    position:  self.info.position))
                
            }.then { (response: Moya.Response) -> Api.User.UpdateResponse in
                try JSONDecoder().decode(Api.User.UpdateResponse.self, from: response.data)
            }.then { (json: Api.User.UpdateResponse) -> Void in
                guard json.status == "ok" else {
                    throw NSError.cancelledError()
                }
            }
    }
}

extension Account.Info: GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
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
