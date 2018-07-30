//
//  AYUIViewAdditions.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func makeCornerRadiusWithValue(_ radius: CGFloat, borderColor: UIColor? = nil) {
        
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
            self.layer.borderWidth = 0.5
        }
    }
}
