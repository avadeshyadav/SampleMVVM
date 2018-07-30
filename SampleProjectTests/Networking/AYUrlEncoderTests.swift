//
//  AYUrlEncoderTests.swift
//  SampleProjectTests
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import XCTest
@testable import SampleProject

class AYUrlEncoderTests: XCTestCase {
    
    func testURLCreation() {
        
        let urlString: String = "https://www.avadesh.com"
        let parameters: [String: String] = ["name": "avadesh"]
        let url = try? URLEncoder().urlWith(string: urlString, parameters: parameters)
        
        XCTAssertNotNil(url, "URLEncoder unable to create a url")
        
        let components = URLComponents(string: url!.absoluteString)
        
        XCTAssertTrue(components!.scheme == "https" , "URLEncoder unable to encode scheme")
        XCTAssertTrue(components!.host == "www.avadesh.com" , "URLEncoder unable to encode scheme")
    }
    
    func testAddingParameters() {
        
        let urlString: String = "https://www.avadesh.com"
        let parameters: [String: String] = ["name": "avadesh"]
        let url = try? URLEncoder().urlWith(string: urlString, parameters: parameters)
        
        let components = URLComponents(string: url!.absoluteString)
        
        XCTAssertTrue(components!.query == "name=avadesh" , "URLEncoder unable to encode paramters")
        
        
    }
}
