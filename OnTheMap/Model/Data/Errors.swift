//
//  Errors.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 25/3/21.
//

import Foundation

enum ErrorMessage: String {
    case general = "Something went wrong, please try again"
    case findLocation = "Something went wrong, please provide another location and try again"
    case updateUserInfo = "Please update your first and last name"
    case overwriteCurrentLocation = "You have already posted a student location. Would you like to overwrite your current location?"
}

enum ErrorTitle: String {
    case addLocation = "Add location error"
    case refreshLocations = "Refresh locations error"
    case findLocation = "Find location error"
    case missingUserData = "Student information doesn't exist"
    case confirmNewLocation = "Confirm a new location"
    case getStudentLocation = "Get student locations error"
    case getUserData = "Get user data error"
    case failedLogin = "Login has failed"
}
