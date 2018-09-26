//
//  File.swift
//  jrkclient
//
//  Created by pimms on 24/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit

enum StreamConfigError: Error {
    case ConfigFileNotFound
    case InvalidConfig
    
    case UnparseableServerResponse
    case FailedToDownloadImage
    case PersistenceFailure
    case InitializationError
    case InvalidURL
}

class StreamConfig {
    private let STREAM_CONFIG_FILE = "JrkStreamConfig.plist"
    private let STREAM_IMAGE_FILE = "JrkStreamMain.png"
    
    private let STREAM_ROOT_URL_KEY = "rootURL"
    private let STREAM_NAME_KEY = "streamName"
    private let STREAM_URL_KEY = "streamURL"
    private let MAIN_IMAGE_URL_KEY = "streamPictureURL"
    
    static func construct(fromURL streamURL: String, callback: @escaping (StreamConfig?,Error?) -> Void) {
        guard let url = URL(string: streamURL) else {
            callback(nil, StreamConfigError.InvalidURL)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard data != nil else {
                DispatchQueue.main.async { callback(nil, error) }
                return
            }
            
            // We need to do some thread-trickery here, as the StreamConfig-constructor will queue
            // another task on the background DispatchQueue, which will deadlock us both. We therefore
            // need to invoke the calls within its' own discrete background-task.
            DispatchQueue.global(qos: .background).async {
                do {
                    let map = data!.toMap()
                    let config = try StreamConfig(withRootURL: streamURL, andMetaResponse: map)
                    DispatchQueue.main.async { callback(config, nil) }
                } catch let err {
                    print("Failed to construct StreamConfig from JRK root URL: \(err.localizedDescription)")
                    DispatchQueue.main.async { callback(nil, err) }
                }
            }
        }
        task.resume()
    }
    
    static func downloadImageSync(imageURL: URL) -> UIImage? {
        let (data, _, err) = URLSession.shared.synchronousDataTask(with: imageURL)
        
        guard err == nil else {
            print("Failed to download image: \(err!.localizedDescription)")
            return nil
        }
        
        guard data != nil else {
            return nil
        }
    
        return UIImage(data: data!)
    }
    
    let rootURL: String
    let streamName: String
    let streamURL: String
    let streamPictureURL: String
    let mainImage: UIImage
    
    private init(withRootURL url: String, andMetaResponse metaMap: [String: AnyObject]) throws {
        self.rootURL = url
        
        guard let streamName = metaMap["streamName"] as? String,
              let playlistURL = metaMap["playlistURL"] as? String,
              let streamPictureURL = metaMap["streamPictureURL"] as? String else {
            throw StreamConfigError.UnparseableServerResponse
        }
        
        guard let mainImage = StreamConfig.downloadImageSync(imageURL: URL(string: streamPictureURL)!) else {
            throw StreamConfigError.FailedToDownloadImage
        }
        
        self.streamName = streamName
        self.streamURL = playlistURL
        self.mainImage = mainImage
        self.streamPictureURL = streamPictureURL
        
        // Time to save this sheiß
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let streamConfigPath = documentsDirectory.appendingPathComponent(STREAM_CONFIG_FILE)
        let mainImagePath = documentsDirectory.appendingPathComponent(STREAM_IMAGE_FILE)
        
        // Save the image
        guard let pngData = UIImagePNGRepresentation(self.mainImage) else {
            throw StreamConfigError.PersistenceFailure
        }
        try pngData.write(to: URL(fileURLWithPath: mainImagePath), options: .atomic)
        
        // Save the config
        let config = NSDictionary(dictionary: [
            STREAM_ROOT_URL_KEY: self.rootURL,
            STREAM_NAME_KEY: self.streamName,
            STREAM_URL_KEY: self.streamURL,
            MAIN_IMAGE_URL_KEY: self.streamPictureURL
        ])
        config.write(toFile: streamConfigPath, atomically: true)
    }
    
    init() throws {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let streamConfigPath = documentsDirectory.appendingPathComponent(STREAM_CONFIG_FILE)
        
        let fileManager = FileManager.default
        if (!fileManager.fileExists(atPath: streamConfigPath)) {
            throw StreamConfigError.ConfigFileNotFound
        }
        
        let configDict = NSDictionary(contentsOfFile: streamConfigPath)
        let imagePath = documentsDirectory.appendingPathComponent(STREAM_IMAGE_FILE)
        
        guard let streamURL = configDict?.object(forKey: STREAM_URL_KEY) as? String,
              let streamName = configDict?.object(forKey: STREAM_NAME_KEY) as? String,
              let rootURL = configDict?.object(forKey: STREAM_ROOT_URL_KEY) as? String,
              let streamPictureURL = configDict?.object(forKey: MAIN_IMAGE_URL_KEY) as? String,
              let mainImage = UIImage(contentsOfFile: imagePath) else {
            throw StreamConfigError.InvalidConfig
        }
        
        self.streamURL = streamURL
        self.streamName = streamName
        self.rootURL = rootURL
        self.streamPictureURL = streamPictureURL
        self.mainImage = mainImage
    }
}
