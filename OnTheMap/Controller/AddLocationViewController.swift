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
        
        navigationItem.title = "Add Location"
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "CANCEL", style: .plain, target: nil, action: nil)
    }
}
