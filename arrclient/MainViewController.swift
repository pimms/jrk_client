//
//  MainViewController.swift
//  jrkclient
//
//  Created by pimms on 16/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import LGSideMenuController
import SwiftEventBus

class MainViewController : LGSideMenuController {
    var streamContext: StreamContext? = nil
    
    deinit {
        SwiftEventBus.unregister(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        leftViewWidth = view.frame.width - 100.0
        
        leftViewPresentationStyle = .slideBelow
        leftViewBackgroundColor = leftViewController?.view.backgroundColor
        rootViewCoverBlurEffectForLeftView = UIBlurEffect(style: .dark)
        rootViewScaleForLeftView = CGFloat(1.2)
        
        prepareContext()
        
        SwiftEventBus.onMainThread(self, name: .streamConfigResetRequestedEvent, handler: {_ in
            guard self.streamContext != nil else {
                return
            }
            self.streamContext!.resetConfiguration()
            self.streamContext = nil
            AppDelegate.singleton?.setActiveStreamContext(nil)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func prepareContext() {
        if let radioVc = rootViewController as? RadioViewController {
            radioVc.streamContext = streamContext
        }
        
        if let configVc = leftViewController as? ConfigViewController {
            configVc.streamContext = streamContext
        }
    }
}
