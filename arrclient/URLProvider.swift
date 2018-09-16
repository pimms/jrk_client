import Foundation

class URLProvider {
    private static let instance: URLProvider = URLProvider()
    private let appConfig = AppConfig()
    
    private func getRootURL() -> String {
        return appConfig.jrkServerURL()
    }
    
    static func infoURL() -> URL {
        let root = instance.getRootURL()
        return URL(string: root + "/live/nowPlaying")!
    }
    
    static func streamURL() -> URL {
        let root = instance.getRootURL()
        return URL(string: root + "/live/playlist.m3u8")!
    }
}
