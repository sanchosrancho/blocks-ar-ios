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


public final class Account {
    
    lazy var info = AccountUser()
    
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
