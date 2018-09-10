//
//  JrkPlayer.swift
//  jrkclient
//
//  Created by pimms on 09/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer

class JrkPlayer: NSObject {
    private let PLAYER_STATUS = "status"
    
    @objc private var player: AVPlayer
    private var playing = false
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    
    override init() {
        let url = URLProvider.streamURL()
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        super.init()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
        } catch let error {
            print("Failed to set category in AudioSession: \(error)")
        }
        
        initializeCommandCenter()
        setupPlayerStatusKVO()
    }
    
    private func initializeCommandCenter() {
        commandCenter.playCommand.addTarget { event in
            print("MPC Play")
            self.togglePlayPause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { event in
            print("MPC Pause")
            self.togglePlayPause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
    }
    
    private func setupPlayerStatusKVO() {
        player.addObserver(self, forKeyPath: PLAYER_STATUS, options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("Observing change in keyPath: \(keyPath ?? "<nil>")")
        
        if (object as? AVPlayer? == player) {
            if (keyPath == PLAYER_STATUS) {
                if (player.status == .readyToPlay) {
                    setActiveSession(true)
                } else {
                    playing = false
                    setActiveSession(false)
                }
            }
        }
    }
    
    func updateNowPlaying(_ info: EpisodeInfo?) {
        if let info = info {
            nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: info.name as Any,
                                         MPMediaItemPropertyArtist: "Radioresepsjonen",
                                         MPMediaItemPropertyAlbumTitle: info.season as Any,
                                         MPNowPlayingInfoPropertyIsLiveStream: true]
        }
    }
    
    func togglePlayPause() {
        if (playing) {
            print("Pausing")
            player.pause()
        } else {
            print("Playing")
            player.play()
        }
        
        playing = !playing
    }
    
    func isPlaying() -> Bool {
        return playing
    }
    
    private func setActiveSession(_ active: Bool) {
        do {
            try audioSession.setActive(active)
        } catch let err {
            NSLog("failed to set session active state: \(err)")
        }
    }
}
