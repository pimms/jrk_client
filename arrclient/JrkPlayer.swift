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

class JrkPlayer {
    private var player: AVPlayer?
    private var playing = false
    private var activatedSession = false
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    
    init() {
        let url = URLProvider.streamURL()
        
        do {
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
            
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
        } catch let error {
            print("Failed to initialize JrkPlayer: \(error)")
        }
    }
    
    func updateNowPlaying(_ info: EpisodeInfo?) {
        nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: info?.name as Any,
                                     MPMediaItemPropertyArtist: "Radioresepsjonen",
                                     MPMediaItemPropertyAlbumTitle: info?.season as Any,
                                     MPNowPlayingInfoPropertyIsLiveStream: true]
    }
    
    func togglePlayPause() {
        activateSession()
        
        if (playing) {
            print("Pausing")
            player!.pause()
        } else {
            print("Playing")
            player!.play()
        }
        
        playing = !playing
    }
    
    func isPlaying() -> Bool {
        return playing
    }
    
    private func activateSession() {
        if (!activatedSession) {
            do {
                try audioSession.setActive(true)
                activatedSession = true
            } catch let err {
                NSLog("failed to activate session: \(err)")
            }
        }
    }
}
