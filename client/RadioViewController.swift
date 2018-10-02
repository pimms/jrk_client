import UIKit
import AVKit
import MediaPlayer

class RadioViewController: UIViewController, RoiPlayerDelegate, PlayButtonDelegate, InfoRetrieverDelegate {
    weak var streamContext: StreamContext?
    
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
        
        streamContext?.roiPlayer.addDelegate(self)
        streamContext?.roiPlayer.addDelegate(playButton!)
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
        let activity = NSUserActivity(activityType: "no.jstien.roi.siri.playRoi")
        activity.title = "Play ROI"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("no.jstien.roi.siri.playRoi")
        view.userActivity = activity
        activity.becomeCurrent()
    }
    
    // -- InfoRetrieverDelegate -- //
    func episodeInfoChanged(_ episodeInfo: EpisodeInfo?) {
        streamContext?.roiPlayer.setNowPlaying(episodeInfo)
        self.infoLabel?.text = episodeInfo?.name
        self.seasonLabel?.text = episodeInfo?.season
    }
    
    // -- PlayButtonDelegate -- //
    func playButtonClicked(_ playButton: PlayButton) {
        streamContext?.roiPlayer.togglePlayPause()
    }
    
    // -- RoiPlayerDelegate -- //
    func roiPlayerStateChanged(state: RoiPlayerState) {
        debugLabel?.text = state.toString()
    }
}

