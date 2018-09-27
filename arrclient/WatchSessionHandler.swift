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
    weak private var streamContext: StreamContext? = nil
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            print("Activating WCSession!")
            session.delegate = self
            session.activate()
        }
    }
    
    func setStreamContext(_ streamContext: StreamContext?) {
        self.streamContext = streamContext
        if self.streamContext != nil {
            self.streamContext?.jrkPlayer.addDelegate(self)
            self.streamContext?.infoRetriever.addDelegate(self)
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let streamContext = self.streamContext {
            episodeInfoChanged(streamContext.infoRetriever.episodeInfo)
            jrkPlayerStateChanged(state: streamContext.jrkPlayer.state)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message["request"] as? String {
            print("Received watch-action request '\(request)'")
            if (request == "play") {
                streamContext?.jrkPlayer.play()
                replyHandler(["status": "ok"])
            } else if (request == "pause") {
                streamContext?.jrkPlayer.pause()
                replyHandler(["status": "ok"])
            } else if (request == "togglePlay") {
                streamContext?.jrkPlayer.togglePlayPause()
                replyHandler(["status": "ok"])
            } else if (request == "status") {
                replyHandler(handleNowPlayingRequest())
            } else {
                replyHandler(["status": "unrecognized request"])
            }
        }
    }
    
    private func handleNowPlayingRequest() -> [String: Any] {
        let info = streamContext?.infoRetriever.episodeInfo
        let state = streamContext?.jrkPlayer.state
        return [
            "status": "ok",
            "title": info?.name as Any,
            "subtitle": info?.season as Any,
            "state": state!.toString()
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
