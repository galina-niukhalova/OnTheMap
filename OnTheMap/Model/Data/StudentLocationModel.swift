//
//  StudentLocationModel.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 10/3/21.
//

import Foundation

struct StudentLocation: Codable {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
}
