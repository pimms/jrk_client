//
//  MainViewController.swift
//  jrkclient
//
//  Created by pimms on 16/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import LGSideMenuController

class MainViewController : LGSideMenuController {
    var streamContext: StreamContext? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        leftViewWidth = view.frame.width - 100.0
        
        leftViewPresentationStyle = .slideBelow
        leftViewBackgroundColor = leftViewController?.view.backgroundColor
        rootViewCoverBlurEffectForLeftView = UIBlurEffect(style: .dark)
        rootViewScaleForLeftView = CGFloat(1.2)
        
        prepareContext()
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
