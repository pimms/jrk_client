import Foundation

class EpisodeInfo: NSObject {
    var name: String?
    var season: String?
    
    // Channel is populated from the StreamConfig
    var channel: String?
    
    init(fromMap map: [String: AnyObject]) {
        if let name = map["name"] as? String {
            self.name = name
        }
        
        if let season = map["season"] as? String {
            self.season = season
        }
    }
}

@objc protocol InfoRetrieverDelegate {
    func episodeInfoChanged(_ episodeInfo: EpisodeInfo?)
}

class InfoRetriever: NSObject {
    var episodeInfo: EpisodeInfo? {
        get {
            return info
        }
    }
    
    private let streamConfig: StreamConfig
    private let urlProvider: URLProvider
    private var delegates: [WeakRef<InfoRetrieverDelegate>] = []
    
    private var info: EpisodeInfo? = nil
    private var shouldLoop = false
    private var task: URLSessionDataTask?
    
    
    init(streamConfig: StreamConfig) {
        self.streamConfig = streamConfig
        self.urlProvider = URLProvider(streamConfig: streamConfig)
        super.init()
        initializeAppLifecycleCallbacks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func addDelegate(_ delegate: InfoRetrieverDelegate) {
        removeDelegate(delegate)
        
        delegates.append(WeakRef(value: delegate))
    }
    
    func removeDelegate(_ delegate: InfoRetrieverDelegate) {
        delegates = delegates.filter { $0.value != nil && $0.value !== delegate }
    }
    
    
    func startRetrievalLoop() {
        if (!shouldLoop) {
            print("Starting InfoRetrievalLoop")
            shouldLoop = true
            startTask()
        }
    }
    
    func stopRetrievalLoop() {
        print("Stopping InfoRetrievalLoop")
        shouldLoop = false
    }
    
    
    private func startTask() {
        let url = urlProvider.infoURL()
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
            info = nil
            dispatchToDelegates()
        } else {
            let new = EpisodeInfo(fromMap: data!.toMap())
            if new.name != info?.name ?? nil {
                new.channel = streamConfig.streamName
                info = new
                dispatchToDelegates()
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

    private func dispatchToDelegates() {
        delegates.forEach { $0.value?.episodeInfoChanged(info) }
    }
    
    // -- app lifecycle -- //
    private func initializeAppLifecycleCallbacks() {
        NotificationCenter.default.addObserver(self, selector:#selector(appWillEnterBackground),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc private func appWillEnterForeground() {
        startRetrievalLoop()
    }
    
    @objc private func appWillEnterBackground() {
        stopRetrievalLoop()
    }
}
