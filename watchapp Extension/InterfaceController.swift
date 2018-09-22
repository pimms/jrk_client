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


class InterfaceController: WKInterfaceController {
    private let session = WCSession.default

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction
    func playButtonClicked() {
        if (session.isReachable) {
            print("[WATCH] Sending message")
            session.sendMessage(["request" : "play"], replyHandler: { (response) in
                print("[WATCH] Received response: ", response)
            }, errorHandler: { (error) in
                print("[WATCH] Error sending message: ", error)
            })
        }
    }
}


extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[WATCH] Session activated")
    }
}
