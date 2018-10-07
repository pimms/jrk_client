//
//  EventLog.swift
//  roiclient
//
//  Created by pimms on 06/10/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation


class Event {
    enum EventError: Error {
        case parseError(String)
    }
    
    let title: String
    let timestamp: Date
    let description: String?
    
    init(fromMap map: [String: AnyObject?]) throws {
        guard let title = map["title"] as? String,
              let timestamp = map["timestamp"] as? String else {
            throw EventError.parseError("Failed to find required attributes 'title' or 'timestamp'")
        }
        
        let trimmedIsoString = timestamp.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        guard let date = ISO8601DateFormatter().date(from: trimmedIsoString) else {
            throw EventError.parseError("Date ('\(timestamp)') was not of expected ISO8601 format")
        }
        
        self.title = title
        self.timestamp = date
        self.description = map["description"] as? String
    }
}

class EventLog {
    enum EventLogError: Error {
        case httpError(String)
    }
    
    private let streamConfig: StreamConfig
    
    init(streamConfig: StreamConfig) {
        self.streamConfig = streamConfig
    }
    
    func fetchLogs(completionHandler: @escaping ([Event]?, Error?) -> Void) {
        let url = URLProvider(streamConfig: streamConfig).eventLogURL()
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let json = data?.deserializeAsJson() as? [[String:AnyObject]] {
                let events = json
                    .reversed()
                    .map {(m) in try? Event(fromMap: m) }
                    .filter { e in e != nil }
                    .map { e in e! }
                completionHandler(events, nil)
            } else {
                completionHandler(nil, error ?? EventLogError.httpError("Server returned no content"))
            }
        }
        task.resume()
    }
}
