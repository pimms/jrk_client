import Foundation

class LogEntry {
    enum LogEntryError: Error {
        case parseError(String)
    }
    
    let title: String
    let timestamp: Date
    let description: String?
    
    init(fromMap map: [String: AnyObject?]) throws {
        guard let title = map["title"] as? String,
              let timestamp = map["timestamp"] as? String else {
            throw LogEntryError.parseError("Failed to find required attributes 'title' or 'timestamp'")
        }
        
        let trimmedIsoString = timestamp.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        guard let date = ISO8601DateFormatter().date(from: trimmedIsoString) else {
            throw LogEntryError.parseError("Date ('\(timestamp)') was not of expected ISO8601 format")
        }
        
        self.title = title
        self.timestamp = date
        self.description = map["description"] as? String
    }
}

class ServerLog {
    enum ServerLogError: Error {
        case httpError(String)
    }
    
    private let streamConfig: StreamConfig
    
    init(streamConfig: StreamConfig) {
        self.streamConfig = streamConfig
    }
    
    func fetchLogs(fromUrl url: URL, completionHandler: @escaping ([LogEntry]?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let json = data?.deserializeAsJson() as? [[String:AnyObject]] {
                let entries = json
                    .reversed()
                    .map {(m) in try? LogEntry(fromMap: m) }
                    .filter { e in e != nil }
                    .map { e in e! }
                completionHandler(entries, nil)
            } else {
                completionHandler(nil, error ?? ServerLogError.httpError("Server returned no content"))
            }
        }
        task.resume()
    }
}
