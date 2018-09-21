import UIKit
import AVKit
import MediaPlayer

import VBFPopFlatButton

class RadioViewController: UIViewController, JrkPlayerDelegate, PlayButtonDelegate {
    private let infoRetriever: InfoRetriever = InfoRetriever()
    
    @IBOutlet
    var jrkPlayer: JrkPlayer?
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSiriActivity()
        
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
        infoRetriever.start({ info in
            self.updatePlayerInfo(info)
        })
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
    
    func onSiriPlayInvocation() {
        jrkPlayer?.play()
    }
    
    func updatePlayerInfo(_ info: EpisodeInfo?) {
        jrkPlayer?.setNowPlaying(info)
        self.infoLabel?.text = info?.name
        self.seasonLabel?.text = info?.season
    }
    
    
    // -- PlayButtonDelegate -- //
    func playButtonClicked(_ playButton: PlayButton) {
        jrkPlayer?.togglePlayPause()
    }
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        debugLabel?.text = state.toString()
    }
}

