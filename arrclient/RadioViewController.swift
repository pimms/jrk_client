import UIKit
import AVKit
import MediaPlayer

import VBFPopFlatButton

class RadioViewController: UIViewController, JrkPlayerDelegate, PlayButtonDelegate, InfoRetrieverDelegate {
    private let jrkPlayer: JrkPlayer = JrkPlayer.shared
    
    @IBOutlet
    var infoLabel: UILabel?
    @IBOutlet
    var seasonLabel: UILabel?
    @IBOutlet
    var debugLabel: UILabel?
    @IBOutlet
    var playButton: PlayButton?
    
    @IBOutlet
    var viewsOmittedFromInitialFade: [UIView]!
    
    deinit {
        jrkPlayer.removeDelegate(self)
        InfoRetriever.shared.removeDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSiriActivity()
        
        jrkPlayer.addDelegate(self)
        InfoRetriever.shared.addDelegate(self)
        InfoRetriever.shared.startRetrievalLoop()
        
        let fadeInDuration = 0.5
        for subview in view.subviews {
            if viewsOmittedFromInitialFade.contains(subview) {
                continue
            }
            subview.alpha = 0.0
            UIView.animate(withDuration: fadeInDuration, animations: { subview.alpha = 1.0 })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    private func setupSiriActivity() {
        let activity = NSUserActivity(activityType: "no.jstien.arrclient.siri.playJrk")
        activity.title = "Play JRK"
        // activity.userInfo = ["color" : "red"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("no.jstien.arrclient.siri.playJrk")
        view.userActivity = activity
        activity.becomeCurrent()
    }
    
    // -- InfoRetrieverDelegate -- //
    func episodeInfoChanged(_ episodeInfo: EpisodeInfo?) {
        jrkPlayer.setNowPlaying(episodeInfo)
        self.infoLabel?.text = episodeInfo?.name
        self.seasonLabel?.text = episodeInfo?.season
    }
    
    // -- PlayButtonDelegate -- //
    func playButtonClicked(_ playButton: PlayButton) {
        jrkPlayer.togglePlayPause()
    }
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        debugLabel?.text = state.toString()
    }
}

