import Foundation

class EpisodeInfo: NSObject {
    var name: String?
    var season: String?
    
    init(fromMap map: [String: AnyObject]) {
        if let name = map["name"] as? String {
            self.name = name
        }
        
        if let season = map["season"] as? String {
            self.season = season
        }
    }
}

func toMap(_ data: Data) -> [String: AnyObject] {
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        return json
    } catch let err {
        print("failed to deserialize json: \(err)")
        return [:]
    }
}

class InfoRetriever: NSObject {
    private var currentName: String? = nil
    private var shouldLoop = false
    
    private var callback: ((EpisodeInfo?) -> Void)?
    private var task: URLSessionDataTask?
    
    func start(_ callback: @escaping (EpisodeInfo?) -> Void) {
        print("Starting info retrieval loop")
        self.callback = callback
        self.callback?(nil)
        shouldLoop = true
        startTask()
    }
    
    func stop() {
        print("Stopping info retrieval loop")
        shouldLoop = false
    }
    
    private func startTask() {
        let url = URLProvider.infoURL()
        task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async {
                self.handleResponse(data: data, error: error)
            }
        }
        task?.resume()
    }
    
    private func handleResponse(data: Data?, error: Error?) {
        if (error != nil || data == nil) {
            print("failed to get info :( \(String(describing: error))")
            self.currentName = nil
            self.callback?(nil)
        } else {
            let info = EpisodeInfo(fromMap: toMap(data!))
            
            if (self.currentName != info.name) {
                self.callback?(info)                
            }
        }
        
        if (shouldLoop) {
            scheduleTask()
        }
    }
    
    private func scheduleTask() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 10.0, execute: {
            self.startTask()
        })
    }
}
