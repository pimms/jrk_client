import UIKit
import AVKit
import MediaPlayer
import VBFPopFlatButton

class ViewController: UIViewController {
    private let infoRetriever: InfoRetriever = InfoRetriever()
    private let jrkPlayer = JrkPlayer()
    
    @IBOutlet
    var playButton: UIButton?
    @IBOutlet
    var infoLabel: UILabel?
    @IBOutlet
    var seasonLabel: UILabel?
    @IBOutlet
    var buttonParentView: UIView?
    
    private var playPauseButton: VBFPopFlatButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
        
        createPlayPauseButton()
    }
    
    private func createPlayPauseButton() {
        let root = self.buttonParentView!.frame
        let frame = CGRect(x: root.width / 4,
                           y: root.height / 4,
                           width: root.width / 2,
                           height: root.height / 2)
        
        playPauseButton = VBFPopFlatButton.init(frame: frame,
                                          buttonType: .buttonForwardType,
                                          buttonStyle: .buttonRoundedStyle,
                                          animateToInitialState: false)
        playPauseButton?.roundBackgroundColor = UIColor.darkGray
        playPauseButton?.lineRadius = 4.0
        playPauseButton?.lineThickness = 4.0
        playPauseButton?.setTintColor(UIColor.white, for: .normal)
        playPauseButton?.setTintColor(UIColor.gray, for: .highlighted)
        playPauseButton?.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        self.buttonParentView!.addSubview(playPauseButton!)
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
            playPauseButton?.animate(to: .buttonPausedType)
        } else {
            playButton?.setImage(UIImage(named: "play.png"), for: .normal)
            playPauseButton?.animate(to: .buttonForwardType)
        }
    }
}

