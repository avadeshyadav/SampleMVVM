//
//  AYUrlEncoderTests.swift
//  SampleProjectTests
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import XCTest
@testable import SampleProject

struct APIURL {
    
}

class AYUrlEncoderTests: XCTestCase, APIURLBuildable {
    
    func hostServer() -> String {
        return "https://www.avadesh.com"
    }
    
    func testURLCreation() {
        
        let parameters: [String: String] = ["name": "avadesh"]
        let url = try? URLEncoder(with: self).encodedParams(parameters)
        
        XCTAssertNotNil(url, "URLEncoder unable to create a url")
        
        let components = URLComponents(string: url!.absoluteString)
        
        XCTAssertTrue(components!.scheme == "https" , "URLEncoder unable to encode scheme")
        XCTAssertTrue(components!.host == "www.avadesh.com" , "URLEncoder unable to encode scheme")
    }
    
    func testAddingParameters() {
        
        let parameters: [String: String] = ["name": "avadesh"]
        let url = try? URLEncoder(with: self).encodedParams(parameters)
        
        let components = URLComponents(string: url!.absoluteString)
        
        XCTAssertTrue(components!.query == "name=avadesh" , "URLEncoder unable to encode paramters")
        
        
    }
}
