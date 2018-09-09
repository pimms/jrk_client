import UIKit
import AVKit
import MediaPlayer

class ViewController: UIViewController {
    private var player: AVPlayer?
    private var playing = false
    private var activatedSession = false
    private let audioSession = AVAudioSession.sharedInstance()
    private let infoRetriever: InfoRetriever = InfoRetriever()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    
    @IBOutlet
    var playButton: UIButton?
    @IBOutlet
    var infoLabel: UILabel?
    @IBOutlet
    var seasonLabel: UILabel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlayer()
        
        playButton?.layer.cornerRadius = 75
        playButton?.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        infoRetriever.start({ info in
            if (info != nil) {
                self.updatePlayerInfo(info!)
            } else {
                self.infoLabel?.text = ""
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        infoRetriever.stop()
    }
    
    func initPlayer() {
        let url = URLProvider.streamURL()
        
        do {
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
            
            commandCenter.playCommand.addTarget { event in
                print("MPC Play")
                self.playButtonClicked()
                return MPRemoteCommandHandlerStatus.success
            }
            commandCenter.pauseCommand.addTarget { event in
                print("MPC Pause")
                self.playButtonClicked()
                return MPRemoteCommandHandlerStatus.success
            }
            commandCenter.nextTrackCommand.isEnabled = false
            commandCenter.previousTrackCommand.isEnabled = false
            commandCenter.skipForwardCommand.isEnabled = false
            commandCenter.skipBackwardCommand.isEnabled = false
        } catch let error {
            print("ERROR: \(error)")
        }
    }
    
    func updatePlayerInfo(_ info: EpisodeInfo?) {
        self.infoLabel?.text = info?.name
        self.seasonLabel?.text = info?.season
        
        nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: info?.name as Any,
                                     MPMediaItemPropertyArtist: "Radioresepsjonen",
                                     MPMediaItemPropertyAlbumTitle: info?.season as Any,
                                     MPNowPlayingInfoPropertyIsLiveStream: true]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction
    func playButtonClicked() {
        activateSession()
        
        if (playing) {
            print("Pausing")
            playButton?.setImage(UIImage(named: "play.png"), for: .normal)
            player!.pause()
        } else {
            print("Playing")
            playButton?.setImage(UIImage(named: "pause.png"), for: .normal)
            player!.play()
        }
        
        playing = !playing
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

