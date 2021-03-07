//
//  CreateSessionRequest.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 7/3/21.
//

import Foundation

struct CreateSessionRequest: Codable {
    let udacity: Udacity
}

struct Udacity: Codable {
    let username: String
    let password: String
}
