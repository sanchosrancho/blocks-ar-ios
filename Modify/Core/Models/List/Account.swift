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

class Account {
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
    
    static let sharedInstance = Account()
    lazy internal var info = Info()
    
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
        return Promise { fulfill, reject in
            
            fetchToken().then { token -> Void in
                self.info.token = token
                fulfill(())
            }.catch { reject($0) }
            
        }
    }
    
    func fetchToken() -> Promise<String> {
        return Promise { fulfill, reject in
            
            let api = MoyaProvider<ModifyApi.User>(plugins: [NetworkLoggerPlugin()])
            api.request(.login(deviceId: self.info.deviceToken)) { result in
                switch result {
                case let .success(response):
                    do {
                        let data = try JSONDecoder().decode(ModifyApi.User.Response.self, from: response.data)
                        fulfill(data.result.token)
                    } catch (let error) {
                        reject(error)
                    }
                    
                case let .failure(error):
                    reject(error)
                }
            }
            
        }
    }
    
    func syncUserInfo() -> Promise<Void> {
        return Promise { fulfill, reject in
            guard let token = self.info.token else { throw NSError.cancelledError() }
            let authPlugin = AccessTokenPlugin(tokenClosure: token)
            let api = MoyaProvider<ModifyApi.User>(plugins: [authPlugin, NetworkLoggerPlugin()])
            
            api.request(.update(
                locale:    self.info.locale,
                pushToken: self.info.platform,
                platform:  self.info.platform,
                position:  self.info.position))
            { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    print(data, statusCode)
                    fulfill(())
                    
                case let .failure(error):
                    print(error)
                    reject(error)
                }
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
