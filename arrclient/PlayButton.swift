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
import VBFPopFlatButton

@objc protocol PlayButtonDelegate {
    @objc func playButtonClicked(_ playButton: PlayButton)
}

@objc class PlayButton: UIControl, JrkPlayerDelegate {
    @IBOutlet
    var delegate: PlayButtonDelegate?
    
    private var playPauseButton: VBFPopFlatButton?
    private var progressView: BufferIndicatorView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
        JrkPlayer.shared.addDelegate(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
        JrkPlayer.shared.addDelegate(self)
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
        
        playPauseButton = VBFPopFlatButton.init(frame: subFrame,
                                                buttonType: FlatButtonType.buttonCloseType,
                                                buttonStyle: .buttonRoundedStyle,
                                                animateToInitialState: true)
        playPauseButton?.roundBackgroundColor = UIColor.darkGray
        playPauseButton?.lineRadius = 4.0
        playPauseButton?.lineThickness = 4.0
        playPauseButton?.setTintColor(UIColor.white, for: .normal)
        playPauseButton?.setTintColor(UIColor.gray, for: .highlighted)
        playPauseButton?.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
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
    
    
    func jrkPlayerStateChanged(state: JrkPlayerState) {
        switch state {
        case .playing:
            playPauseButton?.animate(to: .buttonPausedType)
            break
        case .buffering:
            playPauseButton?.animate(to: .buttonMinusType)
            break
        case .paused, .stopped:
            playPauseButton?.animate(to: .buttonForwardType)
            break
        case .unableToPlay:
            playPauseButton?.animate(to: .buttonCloseType)
            break
        }

        if (state == .buffering) {
            progressView?.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.playPauseButton?.lineThickness = 0.0
            })
        } else {
            progressView?.hide()
            self.playPauseButton?.lineThickness = 4.0
        }
    }
}
