//
//  PlayButton.swift
//  roiclient
//
//  Created by pimms on 13/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit
import DynamicButton

@objc protocol PlayButtonDelegate {
    @objc func playButtonClicked(_ playButton: PlayButton)
}

@objc class PlayButton: UIControl, RoiPlayerDelegate {
    @IBOutlet
    var delegate: PlayButtonDelegate?
    @IBOutlet
    var activityIndicator: UIActivityIndicatorView?
    
    private var playPauseButton: DynamicButton?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    
    private func initSubviews() {
        initButton()
        
        if let indicator = activityIndicator {
            indicator.isHidden = true
            bringSubview(toFront: indicator)
        }
    }
    
    private func initButton() {
        let subFrame = CGRect(x: 10,
                           y: 10,
                           width: frame.width - 20,
                           height: frame.height - 20)
        
        playPauseButton = DynamicButton(style: .none)
        playPauseButton?.frame = subFrame
        playPauseButton?.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        playPauseButton?.backgroundColor = UIColor.darkGray
        playPauseButton?.strokeColor = UIColor.white
        playPauseButton?.layer.cornerRadius = subFrame.width / 2.0
        playPauseButton?.clipsToBounds = true
        addSubview(playPauseButton!)
        sendSubview(toBack: playPauseButton!)
    }
    
    
    @objc private func playButtonClicked() {
        delegate?.playButtonClicked(self)
    }
    
    
    // -- RoiPlayerDelegate -- //
    func roiPlayerStateChanged(state: RoiPlayerState) {
        switch state {
        case .playing:
            playPauseButton?.setStyle(.pause, animated: true)
            break
        case .buffering:
            playPauseButton?.setStyle(.none, animated: true)
            break
        case .paused, .stopped:
            playPauseButton?.setStyle(.play, animated: true)
            break
        case .unableToPlay:
            playPauseButton?.setStyle(.close, animated: true)
            break
        }
        
        if state == .buffering {
            activityIndicator?.startAnimating()
            activityIndicator?.isHidden = false
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
        }
    }
}
