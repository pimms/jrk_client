import Foundation

class StreamContext {
    // Weak-singleton: there should only ever exist one instance
    // of this class.
    static var livingInstances = 0
    
    let streamConfig: StreamConfig
    let infoRetriever: InfoRetriever
    let jrkPlayer: JrkPlayer

    init(streamConfig: StreamConfig) {
        assert(StreamContext.livingInstances == 0)
        StreamContext.livingInstances += 1
        
        self.streamConfig = streamConfig
        self.infoRetriever = InfoRetriever(streamConfig: streamConfig)
        self.jrkPlayer = JrkPlayer(streamConfig: streamConfig)
    }
    
    deinit {
        StreamContext.livingInstances -= 1
    }
    
    func resetConfiguration() {
        jrkPlayer.stop()
        infoRetriever.stopRetrievalLoop()
        StreamConfig.deleteConfiguration()
    }
}
