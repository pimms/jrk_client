import Foundation
import AVKit
import MediaPlayer
import KDEAudioPlayer
import SwiftEventBus


@objc enum JrkPlayerState: Int {
    case buffering
    case stopped
    case unableToPlay
    case paused
    case playing
    
    func toString() -> String {
        switch (self) {
        case .buffering:
            return "buffering"
        case .stopped:
            return "stopped"
        case .unableToPlay:
            return "unableToPlay"
        case .paused:
            return "paused"
        case .playing:
            return "playing"
        }
    }
}

@objc protocol JrkPlayerDelegate {
    func jrkPlayerStateChanged(state: JrkPlayerState)
}

class JrkPlayer: NSObject, AudioPlayerDelegate {
    static let shared = JrkPlayer()
    
    private var delegates: [JrkPlayerDelegate] = []
    
    private var player: AudioPlayer
    private var audioItem: AudioItem
    private let audioSession = AVAudioSession.sharedInstance()
    private var episodeInfo: EpisodeInfo?
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    
    private var playerState: JrkPlayerState = .stopped
    var state: JrkPlayerState {
        get {
            return playerState
        }
    }
    
    
    override init() {
        player = AudioPlayer()
        audioItem = AudioItem(highQualitySoundURL: URLProvider.streamURL())!
        
        super.init()
        player.delegate = self

        initializeAudioSessionCategory()
        initializeCommandCenter()
        initializeAppLifecycleCallbacks()
        initializeDelegateKVO()
        
        SwiftEventBus.onMainThread(self, name: .nowPlayingConfigChangedEvent) { event in
            self.updateNowPlayingInformation()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        SwiftEventBus.unregister(self)
    }
    
    
    private func initializeCommandCenter() {
        commandCenter.playCommand.addTarget { event in
            self.togglePlayPause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { event in
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
    
    private func initializeDelegateKVO() {
        self.addObserver(self, forKeyPath: "delegate1", options: [], context: nil)
        self.addObserver(self, forKeyPath: "delegate2", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        callDelegates()
    }
    
    
    func setNowPlaying(_ info: EpisodeInfo?) {
        episodeInfo = info
        updateNowPlayingInformation()
    }
    
    private func updateNowPlayingInformation() {
        if let info = episodeInfo {
            let appConfig = AppConfig()
            let nowPlayingData = NowPlayingData(withConfig: appConfig, episodeInfo: info)
            
            nowPlaying.nowPlayingInfo = [
                MPMediaItemPropertyTitle: nowPlayingData.trackDisplay,
                MPMediaItemPropertyArtist: nowPlayingData.artistDisplay,
                MPMediaItemPropertyAlbumTitle: nowPlayingData.albumDisplay,
                MPNowPlayingInfoPropertyIsLiveStream: true
            ]
            
            audioItem.artist = nowPlayingData.artistDisplay
            audioItem.album = nowPlayingData.albumDisplay
            audioItem.title = nowPlayingData.trackDisplay
        }
    }
    
    func addDelegate(_ delegate: JrkPlayerDelegate) {
        delegates.append(delegate)
        delegate.jrkPlayerStateChanged(state: playerState)
    }
    
    func removeDelegate(_ delegate: JrkPlayerDelegate) {
        delegates = delegates.filter { $0 !== delegate }
    }
    
    func play() {
        if (playerState == .stopped) {
            player.play(item: audioItem)
        } else if (playerState == .paused) {
            player.resume()
        }
    }
    
    func pause() {
        if (playerState == .playing) {
            player.pause()
        }
    }
    
    func stop() {
        player.stop()
    }
    
    func togglePlayPause() {
        if (playerState == .stopped) {
            player.play(item: audioItem)
        } else if (playerState == .paused) {
            player.resume()
        } else if (playerState == .playing) {
            player.pause()
        }
    }

    private func setPlayerState(_ state: JrkPlayerState) {
        if (state != playerState) {
            playerState = state
            callDelegates()
        }
    }
    
    private func callDelegates() {
        delegates.forEach({ delegate in
            delegate.jrkPlayerStateChanged(state: playerState)
        })
    }
    
    
    // -- app lifecycle -- //
    private func initializeAppLifecycleCallbacks() {
        NotificationCenter.default.addObserver(self, selector:#selector(appDidEnterBackground),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if (playerState != .playing && playerState != .buffering) {
            print("App is unfocused and we're not actively playing – stopping player")
            player.stop()
        }
    }
    
    
    // -- AudioPlayerDelegate -- //
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        print("Changing state from \(from) to \(state)")
        switch (state) {
        case .buffering, .waitingForConnection:
            setPlayerState(.buffering)
            break
        case .paused:
            setPlayerState(.paused)
            break
        case .stopped:
            setPlayerState(.stopped)
            break
        case .playing:
            setPlayerState(.playing)
            break
        case .failed:
            setPlayerState(.unableToPlay)
            break
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {
        // print("rangeload: \(range)")
    }
}
