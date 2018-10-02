//
//  NowPlayingData.swift
//  roiclient
//
//  Created by pimms on 16/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

class NowPlayingData {
    private static let DEFAULT_VALUE = "N/A"
    
    let trackDisplay: String
    let albumDisplay: String
    let artistDisplay: String

    init(episodeInfo: EpisodeInfo) {
        let np = NowPlayingConfiguration()
        
        trackDisplay = NowPlayingData.configAttribute(forConfigValue: np.trackDisplay, episode: episodeInfo)
                            ?? NowPlayingData.DEFAULT_VALUE
        albumDisplay = NowPlayingData.configAttribute(forConfigValue: np.albumDisplay, episode: episodeInfo)
                            ?? NowPlayingData.DEFAULT_VALUE
        artistDisplay = NowPlayingData.configAttribute(forConfigValue: np.artistDisplay, episode: episodeInfo)
                            ?? NowPlayingData.DEFAULT_VALUE
    }

    private static func configAttribute(forConfigValue value: NowPlayingConfigurationValue, episode: EpisodeInfo) -> String? {
        switch (value) {
        case .episodeDate:
            return episode.name
        case .season:
            return episode.season
        case .streamTitle:
            return episode.channel
        }
    }
}
