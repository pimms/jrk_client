import Foundation
import UIKit

class DismissableRootNavigationController: UINavigationController {
    override func viewDidLoad() {
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backButtonClicked))
    }
    
    @objc func backButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
}
