//
//  Socket.swift
//  Modify
//
//  Created by Alex Shevlyakov on 18/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import Starscream
import PromiseKit

final class Socket {
    private let ws: WebSocket
    var token: String? {
        didSet {
            guard let tk = token, tk != "" else {
                if let indx = ws.headers.index(forKey: "Authorization") {
                    ws.headers.remove(at: indx)
                }
                return
            }
            ws.headers["Authorization"] = "Bearer " + tk
        }
    }
    
    init(socketUrl: URL, token: String?) {
        ws = WebSocket(url: socketUrl)
        self.token = token
        ws.delegate = self
    }
    
    public func connect() -> Promise<Void> {
        return Promise { fulfill, reject in
            
            ws.onConnect = { fulfill(()) }
            ws.onDisconnect = { error in
                guard let er = error else { reject(NSError.cancelledError()); return }
                reject(er)
            }
            ws.connect()
            
        }
    }
    
    public func disconnect() -> Promise<Void> {
        return Promise { fulfill, reject in
            
            ws.onDisconnect = { error in
                if let er = error {
                    reject(er)
                    return
                }
                fulfill(())
            }
            ws.disconnect()
            
        }
    }
}

extension Socket: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("---------------------- C O N N E C T E D ----------------------")
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("------------------- D I S C O N N E C T E D -------------------")
        print("websocket is disconnected: \(error?.localizedDescription ?? "unknown error")")
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("---------------------- >> >> >> >> >> got some text: \(text)")
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("---------------------- >> >> >> >> >> got some data: \(data.count)")
    }
}


