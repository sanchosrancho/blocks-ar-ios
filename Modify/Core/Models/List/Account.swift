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

enum AccountError: Error {
    case responseError(Api.ResponseError?)
}

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
        return firstly {
                try Api.run(Api.User.login(deviceId: self.info.deviceToken))
            }.then { response in
                try JSONDecoder().decode(Api.Response<Api.User.Response>.self, from: response.data)
            }.then { (json: Api.Response<Api.User.Response>) -> String in
                guard case .success(let data) = json  else {
                    if case .error(let errorInfo) = json { throw AccountError.responseError(errorInfo) }
                    else { throw AccountError.responseError(nil) }
                }
                return data.token
            }.catch { error in
                print("Fetching token error: ", error.localizedDescription)
            }
    }
    
    func syncUserInfo() -> Promise<Void> {
        return firstly {
                try Api.run(Api.User.update(locale: self.info.locale, pushToken: self.info.platform, platform: self.info.platform, position: self.info.position))
            }.then { response in
                try JSONDecoder().decode(Api.Response<Api.NoReply>.self, from: response.data)
            }.then { (json: Api.Response<Api.NoReply>) -> Void in
                guard case .success = json  else {
                    if case .error(let errorInfo) = json { throw AccountError.responseError(errorInfo) }
                    else { throw AccountError.responseError(nil) }
                }
            }.catch { error in
                print("syncUserInfo error: ", error.localizedDescription)
            }
    }
}
