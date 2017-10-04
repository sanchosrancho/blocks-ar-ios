//
//  Application.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31/08/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import ARKit
import CoreLocation
import PromiseKit

public final class Application {
    
    enum LocationAccuracyState {
        case poor
        case good
        case none
    }
    
    private static let _shared = Application()
    public static var shared: Application {
        return _shared
    }
    
    var state: Application.LocationAccuracyState = .none {
        willSet(newState) {
            guard newState != state else { return }
            NotificationCenter.default.post(name: .locationAccuracyChanged, object: nil, userInfo: ["current": newState])
            if state == .none {
                NotificationCenter.default.post(name: .locationAccuracyStarted, object: nil)
            }
        }
    }
    
    var cameraTrackingState: ARCamera.TrackingState = .notAvailable
    var currentLocation: CLLocation? {
        didSet {
            guard let location = currentLocation else { return }
            adjustifyLocationAccuracyState(location)
            NotificationCenter.default.post(name: .locationUpdated, object: location)
        }
    }
    
    private func adjustifyLocationAccuracyState(_ location: CLLocation) {
        // state = (0...10 ~= location.horizontalAccuracy && 0...5 ~= location.verticalAccuracy) ? .good : .poor
        state = (0...70 ~= location.horizontalAccuracy && 0...12 ~= location.verticalAccuracy) ? .good : .poor
    }
    
    static let socket = Socket(socketUrl: Api.socketURL, token: Account.shared.accessToken)
    
    enum ConnectionStatus {
        case connected
        case error(Error)
        case disconnected
    }
    
    enum ConnectionError: Error {
        case loginNeeded
    }
    
    var connectionStatus = ConnectionStatus.disconnected
}

extension Application {
    func connect() {
        firstly {
            guard let token = Account.shared.accessToken, token != "" else {
                throw ConnectionError.loginNeeded
            }
            return Promise(value: token)
        }.recover { error -> Promise<String> in
            guard case ConnectionError.loginNeeded = error else { throw error }
            return Account.shared.login().then { () -> String in
                guard let token = Account.shared.accessToken, token != "" else {
                    throw ConnectionError.loginNeeded
                }
                return token
            }
        }.then { (token: String) in
            try self.establishSocketConnection(withToken: token)
        }.then {
            self.connectionStatus = .connected
        }.catch { error in
            if (error as NSError).code == 401 {
                self.connectionStatus = .error(ConnectionError.loginNeeded)
            } else {
                self.connectionStatus = .error(error)
            }
        }
    }

    private func establishSocketConnection(withToken token: String) throws -> Promise<Void> {
        let socket = Application.socket
        socket.token = token
        return socket.connect()
    }
    
    func disconnect() {
        let _ = Application.socket.disconnect()
    }
}



class Network {
    
    var timer: Timer?
    let interval: TimeInterval = 10
    
    func restart() {
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: timerReleased)
    }
    
    func timerReleased(timer: Timer) {
        
    }
}
