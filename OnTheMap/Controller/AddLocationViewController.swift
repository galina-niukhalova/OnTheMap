//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit

class AddLocationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleFindLocation(_ sender: Any) {
        let addLocationMapViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationMapViewController") as! AddLocationMapViewController
        
        navigationController!.pushViewController(addLocationMapViewController, animated: true)
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
