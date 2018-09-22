//
//  InterfaceController.swift
//  watchapp Extension
//
//  Created by pimms on 22/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    private let session = WCSession.default
    
    @IBOutlet
    var titleLabel: WKInterfaceLabel?
    @IBOutlet
    var subTitleLabel: WKInterfaceLabel?
    @IBOutlet
    var playPauseButton: WKInterfaceButton?
    
    var isPlaying: Bool = false

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        titleLabel?.setText("")
        subTitleLabel?.setText("")
        playPauseButton?.setEnabled(false)
    }
    
    override func willActivate() {
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    func requestNowPlayingInfo() {
        send(request: "status") { response in
            self.handleNowPlayingResponse(response)
            self.handleJrkStateResponse(response)
        }
    }
    
    
    private func handleNowPlayingResponse(_ response: [String: Any]) {
        titleLabel?.setText(response["title"] as? String ?? "")
        subTitleLabel?.setText(response["subtitle"] as? String ?? "")
    }
    
    private func handleJrkStateResponse(_ response: [String: Any]) {
        playPauseButton?.setEnabled(true)
        if let state = response["state"] as? String {
            isPlaying = (state == "playing" || state == "buffering")
            updateButtonState(playing: isPlaying, assumed: false)
        }
    }
    
    private func updateButtonState(playing: Bool, assumed: Bool) {
        let desc = (playing ? "pause" : "play")
        let title = (assumed ? "--"+desc+"--" : desc)
        
        
        let font = assumed
                ? UIFont.italicSystemFont(ofSize: 15.0)
                : UIFont.systemFont(ofSize: 15.0)
        let attrString = NSAttributedString(string: title, attributes: [.font : font, .foregroundColor: UIColor.white])
        playPauseButton?.setAttributedTitle(attrString)
    }
    
    
    @IBAction
    func playButtonClicked() {
        send(request: "togglePlay") { r in }
        updateButtonState(playing: !isPlaying, assumed: true)
    }
    
    private func send(request: String, replyHandler: @escaping ([String : Any]) -> Void) {
        if session.isReachable {
            print("[WATCH] Requesting '\(request)'")
            session.sendMessage(["request": request], replyHandler: {(response) in
                print("[WATCH] Request '\(request)' reply: \(response)")
                replyHandler(response)
            }, errorHandler: {(error) in
                print("[WATCH] Request '\(request)' failed: \(error)")
            })
        } else {
            print("[WATCH] Cannot complete request '\(request)', session is unreachable")
        }
    }
    
    // -- WCSessionDelegate -- //
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // The iOS app sends us this information when it receives the same signal
        print("[WATCH] Session activated")
        requestNowPlayingInfo()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[WATCH] Received message: \(message)")
        
        if let type = message["type"] as? String {
            switch (type) {
            case "nowPlaying":
                handleNowPlayingResponse(message)
                break
            case "jrkState":
                handleJrkStateResponse(message)
                break
            default:
                print("[WATCH] Unable to handle message of type '\(type)'")
            }
        }
    }
}
