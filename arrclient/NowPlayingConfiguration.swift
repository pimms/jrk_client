//
//  NowPlayingConfiguration.swift
//  jrkclient
//
//  Created by pimms on 16/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

enum NowPlayingConfigurationValue: Int {
    case episodeDate = 0
    case season = 1
    case streamTitle = 2
}

enum NowPlayingConfigurationKey: String {
    case showAsTrack = "showAsTrack"
    case showAsAlbum = "showAsAlbum"
    case showAsArtist = "showAsArtist"
}

class NowPlayingConfiguration {
    let trackDisplay: NowPlayingConfigurationValue
    let albumDisplay: NowPlayingConfigurationValue
    let artistDisplay: NowPlayingConfigurationValue
    
    init() {
        let defaults = UserDefaults.standard
        let rawTrack = defaults.integer(forKey: NowPlayingConfigurationKey.showAsTrack.rawValue,
                                       default: NowPlayingConfigurationValue.episodeDate.rawValue)
        let rawAlbum = defaults.integer(forKey: NowPlayingConfigurationKey.showAsAlbum.rawValue,
                                       default: NowPlayingConfigurationValue.season.rawValue)
        let rawArtist = defaults.integer(forKey: NowPlayingConfigurationKey.showAsArtist.rawValue,
                                        default: NowPlayingConfigurationValue.streamTitle.rawValue)
        
        trackDisplay = NowPlayingConfigurationValue.init(rawValue: rawTrack)!
        albumDisplay = NowPlayingConfigurationValue.init(rawValue: rawAlbum)!
        artistDisplay = NowPlayingConfigurationValue.init(rawValue: rawArtist)!
    }
}
