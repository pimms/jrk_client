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

typealias Payload = [String: Any]


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
            requestNowPlayingInfo()
        }
    }
    
    func requestNowPlayingInfo() {
        send(request: "status")
    }

    
    @IBAction
    func playButtonClicked() {
        send(request: "togglePlay") { r in }
        updateButtonState(playing: !isPlaying, assumed: true)
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

    
    private func send(request: String) {
        send(request: request) { response in
            self.handleMessage(response)
        }
    }
    
    private func send(request: String, replyHandler: @escaping (Payload) -> Void) {
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
    
    
    
    private func handleMessage(_ message: Payload) {
        if let status = message["status"] as? String {
            switch (status) {
            case "configured":
                handleConfiguredMessage(message)
                break
            case "notConfigured":
                handleNotConfiguredMessage(message)
                break
            default:
                print("[WATCH] Unable to handle message of status \(status)")
                break
            }
        }
    }
    
    
    private func handleConfiguredMessage(_ message: Payload) {
        if let type = message["type"] as? String {
            switch (type) {
            case "playerStatus":
                updatePlayerStatus(message)
                break
            default:
                print("[WATCH] Unable to handle message of type '\(type)'")
                break
            }
        }
    }
    
    private func updatePlayerStatus(_ message: Payload) {
        titleLabel?.setText(message["title"] as? String ?? "")
        subTitleLabel?.setText(message["subtitle"] as? String ?? "")
        playPauseButton?.setEnabled(true)
        playPauseButton?.setHidden(false)
        
        if let state = message["jrkState"] as? String {
            isPlaying = (state == "playing" || state == "buffering")
            updateButtonState(playing: isPlaying, assumed: false)
        }
    }
    
    
    private func handleNotConfiguredMessage(_ message: Payload) {
        titleLabel?.setText("Not configured")
        subTitleLabel?.setText("Setup JRK on iPhone")
        playPauseButton?.setEnabled(false)
        playPauseButton?.setHidden(true)
    }
    
    
    
    // -- WCSessionDelegate -- //
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[WATCH] Session activated")
        requestNowPlayingInfo()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("[WATCH] Received message (w/rh) \(message)")
        handleMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("[WATCH] Received message: \(message)")
        handleMessage(message)
    }
}
