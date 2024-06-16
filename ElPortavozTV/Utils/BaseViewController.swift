//
//  BaseViewController.swift
//
//

import UIKit
import MBProgressHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func showLoading() {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    func hideLoading() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func showAlert(title: String?, message: String?, actions: UIAlertAction...) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var actionsAry: [UIAlertAction] = []
        if actions.count > 0 {
            actionsAry += actions
        } else {
            actionsAry += [UIAlertAction(title: "OK", style: .default)]
        }
        for action in actionsAry {
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
    
}

