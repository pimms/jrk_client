//
//  WatchSessionHandler.swift
//  roiclient
//
//  Created by pimms on 22/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import WatchConnectivity

typealias Payload = [String: Any]

class WatchSessionHandler: NSObject, WCSessionDelegate, RoiPlayerDelegate, InfoRetrieverDelegate {
    private let session = WCSession.default
    weak private var streamContext: StreamContext? = nil
    
    private var activeSession = false
    private var lastSentPayload: Payload? = nil
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            print("Activating WCSession!")
            session.delegate = self
            session.activate()
        }
    }
    
    init(withContext context: StreamContext) {
        super.init()
        
        setStreamContext(context)
        
        if (WCSession.isSupported()) {
            print("Activating WCSession!")
            session.delegate = self
            session.activate()
        }
    }
    
    func setStreamContext(_ streamContext: StreamContext?) {
        self.streamContext = streamContext
        self.streamContext?.roiPlayer.addDelegate(self)
        self.streamContext?.infoRetriever.addDelegate(self)
        send(message: createPlayStatusPayload())
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        activeSession = true
        
        if let streamContext = self.streamContext {
            episodeInfoChanged(streamContext.infoRetriever.episodeInfo)
            roiPlayerStateChanged(state: streamContext.roiPlayer.state)
        }
    }
    
    
    private func send(message: Payload) {
        if let previous = lastSentPayload {
            if NSDictionary(dictionary: previous).isEqual(to: message) {
                return
            }
        }
        
        session.sendMessage(message, replyHandler: {_ in
            self.lastSentPayload = message
        }, errorHandler: {error in
            print("Failed to send message to watch: \(error)")
        })
    }
    
    private func createPlayStatusPayload() -> Payload {
        if let context = streamContext {
            let info = context.infoRetriever.episodeInfo
            let state = context.roiPlayer.state
            return [
                "status": "configured",
                "type": "playerStatus",
                "title": info?.name as Any,
                "subtitle": info?.season as Any,
                "roiState": state.toString()
            ]
        } else {
            return createNotConfiguredPayload()
        }
    }
    
    private func createNotConfiguredPayload() -> Payload {
        return [
            "status": "notConfigured"
        ]
    }
    
    
    // -- WCSessionDelegate -- //
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message["request"] as? String {
            print("Received watch-action request '\(request)'")
            if (request == "play") {
                streamContext?.roiPlayer.play()
            } else if (request == "pause") {
                streamContext?.roiPlayer.pause()
            } else if (request == "togglePlay") {
                streamContext?.roiPlayer.togglePlayPause()
            }
            
            let payload = createPlayStatusPayload()
            replyHandler(createPlayStatusPayload())
            lastSentPayload = payload
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        lastSentPayload = nil
        activeSession = false
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        lastSentPayload = nil
    }
    
    // -- InfoRetrieverDelegate -- //
    func episodeInfoChanged(_ episodeInfo: EpisodeInfo?) {
        send(message: createPlayStatusPayload())
    }
    
    // -- RoiPlayerDelegate -- //
    func roiPlayerStateChanged(state: RoiPlayerState) {
        send(message: createPlayStatusPayload())
    }
}
