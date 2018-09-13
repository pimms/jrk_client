import Foundation
import AVKit
import MediaPlayer
import KDEAudioPlayer


enum JrkPlayerState {
    case buffering
    case stopped
    case unableToPlay
    case paused
    case playing
}

protocol JrkPlayerDelegate {
    func jrkPlayerStateChanged(state: JrkPlayerState)
}

class JrkPlayer: NSObject, AudioPlayerDelegate {
    private let player: AudioPlayer
    private var audioItem: AudioItem
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    
    private var delegate: JrkPlayerDelegate?
    private var playerState: JrkPlayerState = .stopped
    
    
    override init() {
        player = AudioPlayer()
        audioItem = AudioItem(highQualitySoundURL: URLProvider.streamURL())!
        
        super.init()
        player.delegate = self

        initializeAudioSessionCategory()
        initializeCommandCenter()
        initializeAppLifecycleCallbacks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func setDelegate(_ delegate: JrkPlayerDelegate) {
        self.delegate = delegate
        self.delegate?.jrkPlayerStateChanged(state: playerState)
    }
    
    func updateNowPlaying(_ info: EpisodeInfo?) {
        if let info = info {
            nowPlaying.nowPlayingInfo = [
                MPMediaItemPropertyTitle: info.name as Any,
                MPMediaItemPropertyArtist: "JRK",
                MPMediaItemPropertyAlbumTitle: info.season as Any,
                MPNowPlayingInfoPropertyIsLiveStream: true
            ]
            
            audioItem.artist = "JRK"
            audioItem.album = info.season
            audioItem.title = info.name
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
            print("Changing player state to \(state)")
            playerState = state
            delegate?.jrkPlayerStateChanged(state: state)
        }
    }
    
    
    // -- app lifecycle -- //
    private func initializeAppLifecycleCallbacks() {
        NotificationCenter.default.addObserver(self, selector:#selector(appWillEnterBackground),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
    }
    
    @objc private func appWillEnterBackground() {
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
        print("rangeload: \(range)")
    }
}
