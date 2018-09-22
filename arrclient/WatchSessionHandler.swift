//
//  WatchSessionHandler.swift
//  jrkclient
//
//  Created by pimms on 22/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSessionHandler: NSObject, WCSessionDelegate {
    static let shared = WatchSessionHandler()
    
    private let session = WCSession.default
    
    override init() {
        super.init()
        
        if (isSupported()) {
            session.delegate = self
            session.activate()
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("RECEIVED MESSAGE: \(message)")
        replyHandler(["message" : "Alt kommer til å bli OK! :)"])
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activation completed with state: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession did become active: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession did deactivate: \(session)")
    }
    
}
