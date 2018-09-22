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
    private let jrkPlayer = JrkPlayer.shared
    
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activation completed with state: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message["request"] as? String {
            print("Received watch-action request '\(request)'")
            if (request == "play") {
                jrkPlayer.play()
                replyHandler(["status": "ok"])
            } else if (request == "pause") {
                jrkPlayer.pause()
                replyHandler(["status": "ok"])
            } else if (request == "nowPlaying") {
                replyHandler(["status": "ok"])
            } else {
                replyHandler(["status": "failed"])
            }
        }
    }
}
