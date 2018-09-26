import Foundation

enum ConfigError: Error {
    case ConfigFileNotFound
    case FailedToParseConfig
}

class AppConfig {
    private let defaults = UserDefaults.standard
    
    func integer(forKey key: String) -> Int? {
        if let val = defaults.value(forKey: key) as? Int {
            return val
        }
        
        return nil
    }
    
    func integer(forKey key: String, default def: Int) -> Int {
        if let val = integer(forKey: key) {
            return val
        }
        
        return def
    }
    
    func set(value val: Any, forKey key: String) {
        defaults.set(val, forKey: key)
    }

}
