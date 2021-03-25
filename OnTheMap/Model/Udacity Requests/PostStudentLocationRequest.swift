//
//  PostStudentLocation.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 24/3/21.
//

import Foundation

struct PostStudentLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
}
