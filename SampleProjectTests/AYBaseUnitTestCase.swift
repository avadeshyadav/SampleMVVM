//
//  AYBaseUnitTestCase.swift
//  SampleProjectTests
//
//  Created by Avadesh Kumar on 01/08/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import XCTest

class AYBaseUnitTestCase: XCTestCase {
    
    func getURLSessionWithMockConfigurations() -> URLSession {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }
}
