import UIKit
import SwiftEventBus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) static var singleton: AppDelegate? = nil
    
    var window: UIWindow?
    private(set) var streamContext: StreamContext?
    private var watchHandler: WatchSessionHandler?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.singleton = self
        watchHandler = WatchSessionHandler()
        
        if let streamConfig = try? StreamConfig() {
            // Do note that there's literally no point in broadcasting (.streamContextChangedEvent) this change, as none of the
            // potential recipients are alive yet.
            streamContext = StreamContext(streamConfig: streamConfig)
        }
        
        SwiftEventBus.on(self, name: .streamContextChangedEvent, queue: nil, handler: {notif in
            let context = notif?.object as? StreamContext
            self.streamContext = context
            self.watchHandler?.setStreamContext(context)
        })
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        streamContext?.jrkPlayer.play()
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

