//
//  ConfigViewController.swift
//  jrkclient
//
//  Created by pimms on 16/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit

class ConfigViewController: UIViewController {
    private let appConfig = AppConfig()
    
    @IBOutlet private var showAsTrack: UISegmentedControl?
    @IBOutlet private var showAsAlbum: UISegmentedControl?
    @IBOutlet private var showAsArtist: UISegmentedControl?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let conf = NowPlayingConfiguration(fromConfig: appConfig)
        showAsTrack?.selectedSegmentIndex = conf.trackDisplay.rawValue
        showAsAlbum?.selectedSegmentIndex = conf.albumDisplay.rawValue
        showAsArtist?.selectedSegmentIndex = conf.artistDisplay.rawValue
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let key = getDefaultsKey(forControl: sender) {
            UserDefaults.standard.set(sender.selectedSegmentIndex,
                                      forKey: key.rawValue)
        }
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
}
