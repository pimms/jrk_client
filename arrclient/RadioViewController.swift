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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.infoLabel?.text = nil
        self.seasonLabel?.text = nil
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
    
    func updatePlayerInfo(_ info: EpisodeInfo?) {
        jrkPlayer?.setNowPlaying(info)
        self.infoLabel?.text = info?.name
        self.seasonLabel?.text = info?.season
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func playButtonClicked(_ playButton: PlayButton) {
        jrkPlayer?.togglePlayPause()
    }
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        debugLabel?.text = state.toString()
    }
}

