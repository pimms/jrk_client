//
//  PlayButton.swift
//  jrkclient
//
//  Created by pimms on 13/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit
import DottedProgressBar
import DynamicButton

@objc protocol PlayButtonDelegate {
    @objc func playButtonClicked(_ playButton: PlayButton)
}

@objc class PlayButton: UIControl, JrkPlayerDelegate {
    @IBOutlet
    var delegate: PlayButtonDelegate?
    
    private var playPauseButton: DynamicButton?
    private var progressView: BufferIndicatorView?
    
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
        initProgressBar()
    }
    
    private func initButton() {
        let subFrame = CGRect(x: frame.height / 4,
                           y: frame.height / 4,
                           width: frame.width / 2,
                           height: frame.height / 2)
        
        playPauseButton = DynamicButton(style: .none)
        playPauseButton?.frame = subFrame
        playPauseButton?.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        playPauseButton?.backgroundColor = UIColor.darkGray
        playPauseButton?.strokeColor = UIColor.white
        addSubview(playPauseButton!)
    }
    
    private func initProgressBar() {
        let subFrame = CGRect(x: frame.width / 4,
                              y: frame.height/2-10,
                              width: frame.width / 2,
                              height: 20)
        progressView = BufferIndicatorView(frame: subFrame)
        addSubview(progressView!)
    }
    
    
    @objc private func playButtonClicked() {
        delegate?.playButtonClicked(self)
    }
    
    
    // -- JrkPlayerDelegate -- //
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        switch state {
        case .playing:
            playPauseButton?.setStyle(.pause, animated: true)
            break
        case .buffering:
            playPauseButton?.setStyle(.dot, animated: true)
            break
        case .paused, .stopped:
            playPauseButton?.setStyle(.play, animated: true)
            break
        case .unableToPlay:
            playPauseButton?.setStyle(.close, animated: true)
            break
        }

        if (state == .buffering) {
            progressView?.show()
        } else {
            progressView?.hide()
        }
    }
}
