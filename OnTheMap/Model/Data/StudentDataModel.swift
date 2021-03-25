//
//  StudentDataModel.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 23/3/21.
//

import Foundation

struct StudentData: Codable {
    let lastName: String
    let firstName: String
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
        case key
    }
}
