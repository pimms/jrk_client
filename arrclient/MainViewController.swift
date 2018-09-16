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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        leftViewWidth = view.frame.width - 150.0
        
        leftViewPresentationStyle = .slideBelow
        leftViewBackgroundColor = leftViewController?.view.backgroundColor
        rootViewCoverBlurEffectForLeftView = UIBlurEffect(style: .dark)
    }
}
