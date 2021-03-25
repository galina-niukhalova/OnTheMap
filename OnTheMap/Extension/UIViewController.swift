//
//  UIViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 20/3/21.
//

import UIKit

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func confirmationAlert(message: String, title: String = "", confirmButtonTitle: String, onConfirm: @escaping () -> Void, onCancel: (() -> Void)?) {
        let confirmationAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: confirmButtonTitle, style: .default, handler: { (action: UIAlertAction!) in
            onConfirm()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            onCancel?()
        }))
        
        self.present(confirmationAlert, animated: true, completion: nil)
    }
}
