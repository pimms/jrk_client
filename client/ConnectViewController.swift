//
//  ConnectViewController.swift
//  roiclient
//
//  Created by pimms on 23/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class ConnectViewController: UIViewController {
    private enum HelpLabelType {
        case info
        case error
    }
    
    private var streamContext: StreamContext? = nil
    private var splashView: SplitSplashView?
    
    @IBOutlet
    var textInput: UITextField?
    @IBOutlet
    var connectButton: UIButton?
    @IBOutlet
    var helpLabel: UILabel?
    @IBOutlet
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        if let context = AppDelegate.singleton?.streamContext {
            streamContext = context
        } else {
            splashView = SplitSplashView()
            view.addSubview(splashView!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator?.isHidden = true
        helpLabel?.text = nil
        
        if streamContext != nil {
            hideAllViews()
        } else {
            showAllViews()
        }
    }
    
    private func hideAllViews() {
        view.subviews.forEach {v in v.isHidden = true}
    }
    
    private func showAllViews() {
        view.subviews.forEach {v in v.isHidden = false}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If a stream is configured, the AppDelegate will instantiate it for us.
        if streamContext != nil {
            performMainSegue()
        } else {
            splashView?.startAnimation(completionHandler: {
                self.textInput?.becomeFirstResponder()
                self.splashView = nil
            })
        }
    }
    
    
    private func performMainSegue() {
        guard streamContext != nil else {
            let alert = UIAlertController(title: "Error", message: "StreamContext is nil", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "oh no", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        performSegue(withIdentifier: "mainSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let main = segue.destination as? MainViewController {
            main.streamContext = streamContext
            
            // We need to release our retain here, there can't exist more than one instance
            // of the StreamContext class simultaneously, and that will happen if the user
            // deletes the configuration.
            self.streamContext = nil
        }
    }
    
    
    @IBAction
    func connectToInputURL() {
        if let url = getInputURL() {
            disableButton()
            
            StreamConfig.construct(fromURL: url, callback: {conf, err in
                if conf != nil {
                    self.streamContext = StreamContext(streamConfig: conf!)
                    SwiftEventBus.post(.streamContextChangedEvent, sender: self.streamContext)
                    self.performMainSegue()
                } else if err != nil {
                    self.handleConfigurationError(err: err!)
                } else {
                    self.setLabelText("Unknown error :(", type: .error)
                }
                
                self.enableButton()
            })
        }
    }
    
    private func handleConfigurationError(err: Error) {
        if let streamErr = err as? StreamConfigError {
            switch (streamErr) {
            case .invalidURL:
                setLabelText("Not a valid URL", type: .error)
                break
            case .unparseableServerResponse:
                setLabelText("Illegible response from server", type: .error)
                break
            case .failedToDownloadImage:
                setLabelText("Failed to download stream image", type: .error)
                break
            case .persistenceFailure:
                setLabelText("Faile to persist configuration", type: .error)
                break
            default:
                setLabelText("Unknown error (\(streamErr.localizedDescription))", type: .error)
                break
            }
        } else {
            self.setLabelText(err.localizedDescription, type: .error)
        }
    }
    
    private func disableButton() {
        connectButton?.setTitle(nil, for: .normal)
        connectButton?.isEnabled = false
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    private func enableButton() {
        connectButton?.setTitle("Connect", for: .normal)
        connectButton?.isEnabled = true
        activityIndicator?.isHidden = true
        activityIndicator?.stopAnimating()
    }
    
    private func getInputURL() -> String? {
        guard let text = textInput?.text, text.count > 0 else {
            return nil
        }
        
        if text.starts(with: "https://") {
            return text
        }
        
        if text.starts(with: "http:") {
            return nil
        }
        
        return "https://" + text
    }
    
    @IBAction
    func textInputChanged() {
        if let text = textInput?.text {
            if text.count >= 5 && text.starts(with: "http:") {
                setLabelText("Only HTTPS is supported", type: .info)
            } else if (text.count >= 4 && !text.starts(with: "http")) {
                setLabelText("No protocol specified - assuming HTTPS", type: .info)
            } else {
                setLabelText(nil, type: .info)
            }
        }
    }
    
    private func setLabelText(_ text: String?, type: HelpLabelType) {
        helpLabel?.text = text
        
        switch (type) {
        case .error:
            helpLabel?.textColor = .red
            break
        case .info:
            helpLabel?.textColor = .lightGray
            break
        }
    }
}
