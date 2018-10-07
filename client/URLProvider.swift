import Foundation

class URLProvider {
    private var streamConfig: StreamConfig
    
    init(streamConfig: StreamConfig) {
        self.streamConfig = streamConfig
    }
    
    func infoURL() -> URL {
        let root = streamConfig.rootURL
        return URL(string: root + "/live/nowPlaying")!
    }
    
    func streamURL() -> URL {
        let root = streamConfig.rootURL
        return URL(string: root + "/live/playlist.m3u8")!
    }
    
    func eventLogURL() -> URL {
        let root = streamConfig.rootURL
        return URL(string: root + "/live/eventlog")!
    }
}
