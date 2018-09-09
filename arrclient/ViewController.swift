import UIKit
import AVKit
import MediaPlayer

class ViewController: UIViewController {
    private let infoRetriever: InfoRetriever = InfoRetriever()
    private let jrkPlayer = JrkPlayer()
    
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
        
        playButton?.layer.cornerRadius = 75
        playButton?.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        infoRetriever.start({ info in
            self.updatePlayerInfo(info)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        infoRetriever.stop()
    }
    
    func updatePlayerInfo(_ info: EpisodeInfo?) {
        jrkPlayer.updateNowPlaying(info)
        self.infoLabel?.text = info?.name
        self.seasonLabel?.text = info?.season
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction
    func playButtonClicked() {
        jrkPlayer.togglePlayPause()
        if (jrkPlayer.isPlaying()) {
            playButton?.setImage(UIImage(named: "pause.png"), for: .normal)
        } else {
            playButton?.setImage(UIImage(named: "play.png"), for: .normal)
        }
    }
}

