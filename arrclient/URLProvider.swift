import Foundation

class URLProvider {
    private static let instance: URLProvider = URLProvider()
    private let appConfig: AppConfig?
    
    init() {
        do {
            try appConfig = AppConfig()
        } catch let error {
            print("Failed to initialize AppConfig: \(error).")
            appConfig = nil
        }
    }
    
    private func getRootURL() -> String {
        if (appConfig != nil) {
            return appConfig!.jrkServerURL()
        }
        
        print("WARNING: No root URL defined!")
        return ""
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
