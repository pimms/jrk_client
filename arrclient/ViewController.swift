import UIKit
import AVKit
import MediaPlayer
import VBFPopFlatButton

class ViewController: UIViewController, JrkPlayerDelegate {
    private let infoRetriever: InfoRetriever = InfoRetriever()
    private let jrkPlayer = JrkPlayer()
    
    @IBOutlet
    var infoLabel: UILabel?
    @IBOutlet
    var seasonLabel: UILabel?
    @IBOutlet
    var debugLabel: UILabel?
    @IBOutlet
    var buttonParentView: UIView?
    
    private var playPauseButton: VBFPopFlatButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
        
        createPlayPauseButton()
        jrkPlayer.setDelegate(self)
    }
    
    private func createPlayPauseButton() {
        let root = self.buttonParentView!.frame
        let frame = CGRect(x: root.width / 4,
                           y: root.height / 4,
                           width: root.width / 2,
                           height: root.height / 2)
        
        playPauseButton = VBFPopFlatButton.init(frame: frame,
                                          buttonType: FlatButtonType.buttonCloseType,
                                          buttonStyle: .buttonRoundedStyle,
                                          animateToInitialState: true)
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
    }
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        switch state {
        case .playing:
            playPauseButton?.animate(to: .buttonPausedType)
            break
        case .readyToPlay:
            playPauseButton?.animate(to: .buttonForwardType)
            break
        case .unableToPlay:
            playPauseButton?.animate(to: .buttonCloseType)
            break
        }
        
        debugLabel?.text = String(describing: state)
    }
}

