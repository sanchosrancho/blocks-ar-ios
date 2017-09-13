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
import DeviceCheck

class Account {
    struct Info {
        let deviceToken: String = { return UIDevice.current.identifierForVendor?.uuidString ?? "" }()
        var userId: String?    { didSet { try? self.createInSecureStore() } }
        var pushToken: String? { didSet { try? self.createInSecureStore() } }
        var token: String?     { didSet { try? self.createInSecureStore() } }
        
        var user: User? {
            guard userId != "" else { return nil }
            let realm = try! Realm()
            return realm.object(ofType: User.self, forPrimaryKey: userId)
        }
        
        init() {
            guard let stored = self.readFromSecureStore()?.data else { return }
            self.userId = stored["userId"] as? String
            self.pushToken = stored["pushToken"] as? String
            self.token = stored["token"] as? String
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
            let api = MoyaProvider<ModifyApi.User>(plugins: [NetworkLoggerPlugin()])
            api.request(.login(deviceId: self.info.deviceToken)) { result in
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
