//
//  WatchSessionHandler.swift
//  jrkclient
//
//  Created by pimms on 22/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSessionHandler: NSObject, WCSessionDelegate, JrkPlayerDelegate, InfoRetrieverDelegate {
    static let shared = WatchSessionHandler()
    
    private let session = WCSession.default
    private let jrkPlayer = JrkPlayer.shared
    
    override init() {
        super.init()
        
        if (isSupported()) {
            session.delegate = self
            session.activate()
            
            InfoRetriever.shared.addDelegate(self)
            JrkPlayer.shared.addDelegate(self)
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        episodeInfoChanged(InfoRetriever.shared.episodeInfo)
        jrkPlayerStateChanged(state: JrkPlayer.shared.state)
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
            } else if (request == "togglePlay") {
                jrkPlayer.togglePlayPause()
                replyHandler(["status": "ok"])
            } else if (request == "status") {
                replyHandler(handleNowPlayingRequest())
            } else {
                replyHandler(["status": "unrecognized request"])
            }
        }
    }
    
    private func handleNowPlayingRequest() -> [String: Any] {
        let info = InfoRetriever.shared.episodeInfo
        let state = JrkPlayer.shared.state
        return [
            "status": "ok",
            "title": info?.name as Any,
            "subtitle": info?.season as Any,
            "state": state.toString()
        ]
    }
    
    // -- InfoRetrieverDelegate -- //
    func episodeInfoChanged(_ episodeInfo: EpisodeInfo?) {
        let message = [
            "type": "nowPlaying",
            "title": episodeInfo?.name as Any,
            "subtitle": episodeInfo?.season as Any
        ]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: {error in
            print("Failed to send message to watch: \(error)")
        })
    }
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        let message = [
            "type": "jrkState",
            "state": state.toString()
        ]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: {error in
            print("Failed to send message to watch: \(error)")
        })
    }
}
