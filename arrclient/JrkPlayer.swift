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


enum JrkPlayerState {
    case unableToPlay
    case readyToPlay
    case playing
}

protocol JrkPlayerDelegate {
    func jrkPlayerStateChanged(state: JrkPlayerState)
}

class JrkPlayer: NSObject {
    private let PLAYER_STATUS = "status"
    private let PLAYER_RATE = "rate"
    private let PLAYER_ERROR = "error"
    
    @objc private var player: AVPlayer
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    
    private var delegate: JrkPlayerDelegate?
    private var playerState: JrkPlayerState = .unableToPlay
    
    override init() {
        let url = URLProvider.streamURL()
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        super.init()
        
        initializeAudioSessionCategory()
        initializeCommandCenter()
        setupPlayerKVOs()
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
    
    private func initializeAudioSessionCategory() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
        } catch let error {
            print("Failed to set category in AudioSession: \(error)")
        }
    }
    
    private func setupPlayerKVOs() {
        player.addObserver(self, forKeyPath: PLAYER_STATUS, options: [], context: nil)
        player.addObserver(self, forKeyPath: PLAYER_RATE, options: [.new], context: nil)
        player.addObserver(self, forKeyPath: PLAYER_ERROR, options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("Observing change in keyPath: \(keyPath ?? "<nil>")")
        
        if (object as? AVPlayer? == player) {
            checkAVPlayerForState()
        }
    }
    
    func setDelegate(_ delegate: JrkPlayerDelegate) {
        self.delegate = delegate
        self.delegate?.jrkPlayerStateChanged(state: playerState)
    }
    
    func updateNowPlaying(_ info: EpisodeInfo?) {
        if let info = info {
            nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: info.name as Any,
                                         MPMediaItemPropertyArtist: "JRK",
                                         MPMediaItemPropertyAlbumTitle: info.season as Any,
                                         MPNowPlayingInfoPropertyIsLiveStream: true]
        }
    }
    
    func togglePlayPause() {
        // Note that the KVO on the AVPlayer is responsible
        // for updating the JrkPlayerState!
        if (playerState == .readyToPlay) {
            player.play()
        } else if (playerState == .playing) {
            player.pause()
        }
    }
    
    private func checkAVPlayerForState() {
        var unhandled = false
        
        if (player.isPlaying) {
            // Coolio! :)
            setPlayerState(.playing)
        } else if (player.status == .readyToPlay) {
            setPlayerState(.readyToPlay)
        } else if (player.status == .failed) {
            setPlayerState(.unableToPlay)
        } else {
            print("Unhandled AVPlayer state!")
            unhandled = true
        }
        
        if let error = player.error {
            if (unhandled) {
                print("Defaulting to .unableToPlay")
                setPlayerState(.unableToPlay)
            }
            print("AVPlayer error: \(error.localizedDescription)")
        }
    }
    
    
    private func setActiveSession(_ active: Bool) {
        do {
            try audioSession.setActive(active)
        } catch let err {
            NSLog("failed to set session active state: \(err)")
        }
    }

    private func setPlayerState(_ state: JrkPlayerState) {
        if (state != playerState) {
            print("Changing player state to \(state)")
            playerState = state
            delegate?.jrkPlayerStateChanged(state: state)
        }
    }
}
