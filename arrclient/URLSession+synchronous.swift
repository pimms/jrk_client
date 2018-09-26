//
//  NSURLSession+synchronous.swift
//  jrkclient
//
//  Created by pimms on 24/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .now() + 10.0)
        
        return (data, response, error)
    }
}
