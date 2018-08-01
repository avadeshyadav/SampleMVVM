//
//  AYMovieRequestTests.swift
//  SampleProjectTests
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import XCTest
@testable import SampleProject

class AYMovieRequestTests: AYBaseUnitTestCase {
    
    var loader: APIRequestLoader<MovieListRequest>!

    override func setUp() {
        super.setUp()
        
        let request = MovieListRequest()
        let urlSession = getURLSessionWithMockConfigurations()
        
        loader = APIRequestLoader(apiRequest: request, urlSession: urlSession)
    }
    
    func testAPISuccess() {
       
        let movieId: Int = 157350
        let mockJSON: [String: Any] = ["page":2,"results":[["backdrop_path":"/g6WT9zxATzTy9NVu2xwbxDAxvjd.jpg","genre_ids":[28,12,878],"id": movieId,"original_language":"en","overview":"Trislearnsthatshe's been classified as Divergent and too late.","poster_path":"/yTtx2ciqk4XdN1oKhMMDy3f5ue3.jpg","release_date":"2014-03-14","title":"Divergent"]],"total_pages":18597,"total_results":371921]
            
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("page=2"), true)
            return (HTTPURLResponse(), mockJSON.toJSONData()!)
        }
       
        let expectation = XCTestExpectation(description: "response")
        loader.loadAPIRequest(requestData: "2", completionHandler: { (response, error) in
            
            expectation.fulfill()
            XCTAssertNotNil(response, "Response must not be nil")
            XCTAssertTrue(response!.page == 2, "Page number must be 2 instead of:\(String(describing: response!.page))")
            XCTAssertTrue(response!.movies.count == 1, "Number of movies must be 1 instead of:\(String(describing: response!.movies.count))")
            XCTAssertTrue(response!.movies.first!.id == movieId, "Parsing of movie do not seem to be correct, expected: \(movieId) received:\(String(describing: response!.movies.first!.id))")
        })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testAPIFailure() {
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("page=2"), true)
            return (HTTPURLResponse(url: URL(string: "https:www.avadeh.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!, Data())
        }
        
        let expectation = XCTestExpectation(description: "response")
        loader.loadAPIRequest(requestData: "2", completionHandler: { (response, error) in
            
            expectation.fulfill()
            XCTAssertNil(response, "Response must be nil, as it should be an error case")
        })
        
        wait(for: [expectation], timeout: 1)
    }
    
}

