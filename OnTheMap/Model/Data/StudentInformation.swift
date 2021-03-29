//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 29/3/21.
//

import Foundation

struct StudentInformation {
    var locations: [StudentLocation] = []
    var studentPersonalInformation: StudentData?
    
    static var sharedInstance = StudentInformation()
}
