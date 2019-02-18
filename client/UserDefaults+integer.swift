import Foundation

extension UserDefaults {
    func integer(forKey key: String) -> Int? {
        if let val = value(forKey: key) as? Int {
            return val
        }
        
        return nil
    }
    
    func integer(forKey key: String, default def: Int) -> Int {
        if let val = self.value(forKey: key) as? Int {
            return val
        }
        
        return def
    }
    
    func set(value val: Any, forKey key: String) {
        set(val, forKey: key)
    }
}
