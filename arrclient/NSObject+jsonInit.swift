import Foundation

extension NSObject{
    convenience init(jsonInit: String) {
        self.init()
        
        if let jsonData = jsonInit.data(using: String.Encoding.utf8, allowLossyConversion: false)
        {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                
                // Loop
                for (key, value) in json {
                    let keyName = key as String
                    let keyValue: String = value as! String
                    
                    // If property exists
                    if (self.responds(to: NSSelectorFromString(keyName))) {
                        self.setValue(keyValue, forKey: keyName)
                    }
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        else
        {
            print("json is of wrong format!")
        }
    }
}
