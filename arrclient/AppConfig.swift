import Foundation

enum ConfigError: Error {
    case ConfigFileNotFound
    case FailedToParseConfig
}

class AppConfig {
    private let config: NSDictionary
    
    init() throws {
        guard let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist") else {
            throw ConfigError.ConfigFileNotFound
        }
    
        guard let dict = NSDictionary(contentsOfFile: path) else {
            throw ConfigError.FailedToParseConfig
        }
        
        config = dict
    }
    
    func jrkServerURL() -> String {
        return config["jrkServerURL"] as! String
    }
}
