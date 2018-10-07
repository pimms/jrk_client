//
//  EventLogViewController.swift
//  roiclient
//
//  Created by pimms on 06/10/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation
import UIKit

class EventLogViewController: UITableViewController {
    var streamConfig: StreamConfig?
    var events: [Event] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        createNavigationBackButtonIfNeeded()
        tableView.tableFooterView = UIView()
        
        streamConfig = AppDelegate.singleton?.streamContext?.streamConfig
        guard streamConfig != nil else {
            preconditionFailure("streamConfig must be defined")
        }
        
        let eventLog = EventLog(streamConfig: streamConfig!)
        eventLog.fetchLogs() {(events, error) in
            if events != nil {
                self.events = events!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.showFailureDialog(error)
            }
        }
    }
    
    private func createNavigationBackButtonIfNeeded() {
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backButtonClicked))
    }
    
    @objc private func backButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showFailureDialog(_ err: Error?) {
        let msg = "Could not retrieve server event logs. \(err?.localizedDescription ?? "")"
        let alert = UIAlertController(title: "Failed to get logs", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    // -- UITableViewDataSource -- //
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eventCell: EventCell?
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as? EventCell {
            eventCell = cell
        } else {
            eventCell = EventCell()
        }
        
        eventCell!.updateViews(withEvent: events[indexPath.row])
        return eventCell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104.0
    }
}


class EventCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var timestampLabel: UILabel?
    
    func updateViews(withEvent event: Event) {
        titleLabel?.text = event.title
        descriptionLabel?.text = event.description ?? "no description"
        
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: event.timestamp, to: now)
        
        if components.hour! >= 1 {
            timestampLabel?.text = "\(components.hour!)h"
        } else if components.minute! >= 1 {
            timestampLabel?.text = "\(components.minute!)m"
        } else {
            timestampLabel?.text = "now"
        }
    }
}
