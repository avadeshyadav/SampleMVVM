//
//  NetworkManagerTests.swift
//  SampleProjectTests
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import XCTest
@testable import SampleProject

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        
    }
}

protocol JSONMockable {
    func getMockJSON() -> [String: Any]
}

extension JSONMockable {
    
    func getMockJSON() -> [String: Any] {
        
        let mockJSON: [String: Any] = ["page":2,"results":[["backdrop_path":"/g6WT9zxATzTy9NVu2xwbxDAxvjd.jpg","genre_ids":[28,12,878],"id": 157350,"original_language":"en","overview":"Trislearnsthatshe's been classified as Divergent and too late.","poster_path":"/yTtx2ciqk4XdN1oKhMMDy3f5ue3.jpg","release_date":"2014-03-14","title":"Divergent"]],"total_pages":18597,"total_results":371921]
        return mockJSON
    }
}


class MockAPIRequest: APIRequest {
    
    var numberOfTimesMakeRequestCalled: Int = 0
    var numberOfTimesParseResponseCalled: Int = 0
    var numberOfTimesShouldCacheRsponseCalled: Int = 0

    func makeRequest(from urlString: String) throws -> URLRequest {
        numberOfTimesMakeRequestCalled = numberOfTimesMakeRequestCalled + 1
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        return urlRequest
    }
    
    func parseResponse(data: Data) throws -> Data {
        numberOfTimesParseResponseCalled = numberOfTimesParseResponseCalled + 1
        return data
    }
    
    func shouldCacheResponse() -> Bool {
        numberOfTimesShouldCacheRsponseCalled = numberOfTimesShouldCacheRsponseCalled + 1
        return true
    }
}

class APIRequestLoaderTests: AYBaseUnitTestCase, JSONMockable {
   
    var loader: APIRequestLoader<MockAPIRequest>!
    let request = MockAPIRequest()

    override func setUp() {
        super.setUp()
        
        let urlSession = getURLSessionWithMockConfigurations()
        loader = APIRequestLoader(apiRequest: request, urlSession: urlSession)
    }
    
    func testAPISuccess() {
        
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), self.getMockJSON().toJSONData()!)
        }
        
        let expectation = XCTestExpectation(description: "response")
        loader.loadAPIRequest(requestData: "2", completionHandler: { [weak self] (response, error) in
            
            expectation.fulfill()
            XCTAssertTrue(self?.request.numberOfTimesMakeRequestCalled == 1, "APIRequestLoader: Issue with make request calling")
            XCTAssertTrue(self?.request.numberOfTimesParseResponseCalled == 1, "APIRequestLoader: Issue with parse response calling")
            XCTAssertTrue(self?.request.numberOfTimesShouldCacheRsponseCalled == 1, "APIRequestLoader: Issue with should cache response calling")
        })
        
        wait(for: [expectation], timeout: 1)
    }
}
