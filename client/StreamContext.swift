//
//  StreamContext.swift
//  roiclient
//
//  Created by pimms on 24/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

class StreamContext {
    // Weak-singleton: there should only ever exist one instance
    // of this class.
    static var livingInstances = 0
    
    let streamConfig: StreamConfig
    let infoRetriever: InfoRetriever
    let roiPlayer: RoiPlayer

    init(streamConfig: StreamConfig) {
        assert(StreamContext.livingInstances == 0)
        StreamContext.livingInstances += 1
        
        self.streamConfig = streamConfig
        self.infoRetriever = InfoRetriever(streamConfig: streamConfig)
        self.roiPlayer = RoiPlayer(streamConfig: streamConfig)
    }
    
    deinit {
        StreamContext.livingInstances -= 1
    }
    
    func resetConfiguration() {
        roiPlayer.stop()
        infoRetriever.stopRetrievalLoop()
        StreamConfig.deleteConfiguration()
    }
}
