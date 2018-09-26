import UIKit
import AVKit
import MediaPlayer

import VBFPopFlatButton

class RadioViewController: UIViewController, JrkPlayerDelegate, PlayButtonDelegate, InfoRetrieverDelegate {
    var streamContext: StreamContext?
    
    @IBOutlet
    var imageView: UIImageView?
    @IBOutlet
    var infoLabel: UILabel?
    @IBOutlet
    var seasonLabel: UILabel?
    @IBOutlet
    var debugLabel: UILabel?
    @IBOutlet
    var playButton: PlayButton?
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
        
        streamContext?.jrkPlayer.addDelegate(self)
        streamContext?.jrkPlayer.addDelegate(playButton!)
        streamContext?.infoRetriever.addDelegate(self)
        streamContext?.infoRetriever.startRetrievalLoop()
        
        imageView?.image = streamContext?.streamConfig.mainImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSiriActivity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    private func setupSiriActivity() {
        let activity = NSUserActivity(activityType: "no.jstien.arrclient.siri.playJrk")
        activity.title = "Play JRK"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("no.jstien.arrclient.siri.playJrk")
        view.userActivity = activity
        activity.becomeCurrent()
    }
    
    // -- InfoRetrieverDelegate -- //
    func episodeInfoChanged(_ episodeInfo: EpisodeInfo?) {
        streamContext?.jrkPlayer.setNowPlaying(episodeInfo)
        self.infoLabel?.text = episodeInfo?.name
        self.seasonLabel?.text = episodeInfo?.season
    }
    
    // -- PlayButtonDelegate -- //
    func playButtonClicked(_ playButton: PlayButton) {
        streamContext?.jrkPlayer.togglePlayPause()
    }
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        debugLabel?.text = state.toString()
    }
}

