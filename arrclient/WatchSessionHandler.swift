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
    private let session = WCSession.default
    private let infoRetriever: InfoRetriever
    private let jrkPlayer: JrkPlayer
    
    init(streamContext: StreamContext) {
        self.jrkPlayer = streamContext.jrkPlayer
        self.infoRetriever = streamContext.infoRetriever
        
        super.init()
        
        if (isSupported()) {
            print("Activating WCSession!")
            session.delegate = self
            session.activate()
            infoRetriever.addDelegate(self)
            jrkPlayer.addDelegate(self)
        }
    }
    
    func deactivate() {
        print("EXPERIMENTAL DEACTIVATION OF WCSESSION")
        session.delegate = nil
    }
    
    func isSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        episodeInfoChanged(self.infoRetriever.episodeInfo)
        jrkPlayerStateChanged(state: self.jrkPlayer.state)
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
        let info = infoRetriever.episodeInfo
        let state = jrkPlayer.state
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
