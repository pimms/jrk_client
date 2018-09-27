//
//  ConfigViewController.swift
//  jrkclient
//
//  Created by pimms on 16/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class ConfigViewController: UIViewController {
    weak var streamContext: StreamContext?
    
    
    @IBOutlet private var showAsTrack: UISegmentedControl?
    @IBOutlet private var trackLabel: UILabel?
    
    @IBOutlet private var showAsAlbum: UISegmentedControl?
    @IBOutlet private var albumLabel: UILabel?
    
    @IBOutlet private var showAsArtist: UISegmentedControl?
    @IBOutlet private var artistLabel: UILabel?
    
    @IBOutlet private var urlLabel: UILabel?
    
    
    override func loadView() {
        super.loadView()
        trackLabel?.text = nil
        albumLabel?.text = nil
        artistLabel?.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let conf = NowPlayingConfiguration()
        showAsTrack?.selectedSegmentIndex = conf.trackDisplay.rawValue
        showAsAlbum?.selectedSegmentIndex = conf.albumDisplay.rawValue
        showAsArtist?.selectedSegmentIndex = conf.artistDisplay.rawValue
        
        urlLabel?.text = streamContext!.streamConfig.rootURL
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLabels()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let key = getDefaultsKey(forControl: sender) {
            UserDefaults.standard.set(value: sender.selectedSegmentIndex, forKey: key.rawValue)
            SwiftEventBus.post(.nowPlayingConfigChangedEvent)
            updateLabels()
        }
    }
    
    @IBAction func deleteConfigButtonClicked() {
        SwiftEventBus.post(.streamConfigResetRequestedEvent)
    }
    
    private func getDefaultsKey(forControl control: UISegmentedControl) -> NowPlayingConfigurationKey? {
        switch (control) {
        case showAsTrack:
            return .showAsTrack
        case showAsAlbum:
            return .showAsAlbum
        case showAsArtist:
            return .showAsArtist
        default:
            print("Unable to resolve defaults key for UISegmentedControl: \(control)")
            return nil
        }
    }
    
    private func updateLabels() {
        if let episodeInfo = streamContext?.infoRetriever.episodeInfo {
            let nowPlayingData = NowPlayingData(episodeInfo: episodeInfo)
            trackLabel?.text = nowPlayingData.trackDisplay
            albumLabel?.text = nowPlayingData.albumDisplay
            artistLabel?.text = nowPlayingData.artistDisplay
        }
    }
}
