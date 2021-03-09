//
//  RoundButton.swift
//  OnTheMap
//
//  Created by Galina Niukhalova on 6/3/21.
//

import Foundation
import UIKit

class RoundButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
    }
    
}
