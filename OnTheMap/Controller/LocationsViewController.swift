//
//  LocationsViewController.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import UIKit
import Foundation

class LocationsViewController: NavigationViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    let tableCellId = "LocationsTableCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellId, for: indexPath) as! LocationTableViewCell
        
        let location = studentLocations[indexPath.row]
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = studentLocations[indexPath.row]
        
        let app = UIApplication.shared
        if let url = URL(string: location.mediaURL) {
            app.open(url)
        }
    }
    
    
    override func onAddLocationFinish (location: StudentLocation?) {
        guard let _ = location else {
            return
        }
        
        tableView.reloadData()
    }
}
