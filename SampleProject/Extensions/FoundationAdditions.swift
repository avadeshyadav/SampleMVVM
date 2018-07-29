//
//  FoundationAdditions.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation


extension Data {
    
    func toJSONObject() -> Any? {
        
        let object = try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments)
        return object
    }
}
