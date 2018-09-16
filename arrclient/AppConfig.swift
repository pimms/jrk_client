import Foundation

enum ConfigError: Error {
    case ConfigFileNotFound
    case FailedToParseConfig
}

class AppConfig {
    private let config: NSDictionary
    private let defaults = UserDefaults.standard
    
    init() {
        let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        config = dict!
    }
    
    func jrkServerURL() -> String {
        return config["jrkServerURL"] as! String
    }

    
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
