import Foundation
import UIKit

class EventCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var timestampLabel: UILabel?
    
    func updateViews(withEntry entry: LogEntry) {
        titleLabel?.text = entry.title
        descriptionLabel?.text = entry.description ?? "no description"
        
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: entry.timestamp, to: now)
        
        if components.hour! >= 1 {
            timestampLabel?.text = "\(components.hour!)h"
        } else if components.minute! >= 1 {
            timestampLabel?.text = "\(components.minute!)m"
        } else {
            timestampLabel?.text = "now"
        }
    }
}

class ServerLogController: UITableViewController {
    var streamConfig: StreamConfig?
    var logEntries: [LogEntry] = []
    
    /*lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        return control!
    }()*/
    
    func serverLogDataURL() -> URL {
        preconditionFailure("Override me!")
    }

    override func viewDidLoad() {
        tableView.tableFooterView = UIView()
        
        streamConfig = AppDelegate.singleton?.streamContext?.streamConfig
        guard streamConfig != nil else {
            preconditionFailure("streamConfig must be defined")
        }
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        refreshContent()
    }
    
    @objc private func refreshContent() {
        let serverLog = ServerLog(streamConfig: streamConfig!)
        let url = serverLogDataURL()

        serverLog.fetchLogs(fromUrl: url) {(entries, error) in
            if entries != nil {
                self.logEntries = entries!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.showFailureDialog(error)
            }
            
            // We get this weird behavior where the ActivityIndicator lingers over
            // the top row if we dismiss is immediately, so sleep for a wee bit
            // before actually dismissing it.
            usleep(500 * 1000)
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func showFailureDialog(_ err: Error?) {
        let msg = "Could not retrieve server logs. \(err?.localizedDescription ?? "")"
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
        return logEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eventCell: EventCell?
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as? EventCell {
            eventCell = cell
        } else {
            eventCell = EventCell()
        }
        
        eventCell!.updateViews(withEntry: logEntries[indexPath.row])
        return eventCell!
    }
}


class ServerEventLogsController: ServerLogController {
    override func serverLogDataURL() -> URL {
        return URLProvider(streamConfig: streamConfig!).eventLogURL()
    }
}

class EpisodeHistoryController: ServerLogController {
    override func serverLogDataURL() -> URL {
        return URLProvider(streamConfig: streamConfig!).episodeLogURL()
    }
}
