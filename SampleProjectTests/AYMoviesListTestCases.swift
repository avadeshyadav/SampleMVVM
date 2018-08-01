//
//  AYMoviesListTestCases.swift
//  SampleProjectTests
//
//  Created by Avadesh Kumar on 01/08/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import XCTest
@testable import SampleProject

class AYMovieListViewModelTestCases: AYBaseUnitTestCase, JSONMockable {
    
    var model: AYMovieListViewModel!

    override func setUp() {
        super.setUp()
        
        let urlSession = getURLSessionWithMockConfigurations()
        model = AYMovieListViewModel(APIRequestLoader(apiRequest: MovieListRequest(), urlSession: urlSession))
        model.movieApiReponse.page = 1
        model.movieApiReponse.numberOfPages = 2
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanLoadNextPageFunctionalityWithRefreshing() {
        model.isUserRefreshingList = true
        XCTAssertFalse(model.canLoadNextPage(), "AYMovieListViewModel must not load data while refreshing in progress")
    }
    
    func testCanLoadNextPageFunctionalityWithAlreadyLoadingData() {

        model.isLoadingNextPageResults = true
        XCTAssertFalse(model.canLoadNextPage(), "AYMovieListViewModel must not load data while loading next page data in progress")
    }
    
    func testCanLoadNextPageFunctionalityWithoutRefreshingAndLoadingNextPageData() {
        
        model.isUserRefreshingList = false
        model.isLoadingNextPageResults = false
        
        XCTAssertTrue(model.canLoadNextPage(), "AYMovieListViewModel must load next page data if refreshing and next page loading isn't in progress")
    }
    
    func testCanLoadNextPageFunctionalityWithLastPage() {
        
        model.isUserRefreshingList = false
        model.isLoadingNextPageResults = false
        model.movieApiReponse.page = 2
        model.movieApiReponse.numberOfPages = 2
        
        XCTAssertFalse(model.canLoadNextPage(), "AYMovieListViewModel must not load next page data if last page loaded")
    }
    
    func testLoadingMoviesList() {
        
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), self.getMockJSON().toJSONData()!)
        }
        
        let expectation = XCTestExpectation(description: "response")
        model.movieApiReponse.page = 0
        model.getMoviesList { (result) in
            
            expectation.fulfill()
            
            switch result {
            case .success:
                XCTAssertTrue(self.model.movieApiReponse.movies.count == 1, "AYMovieListViewModel's getMoviesList method does not work as expected.")
                
            case .failure:
                XCTFail("AYMovieListViewModel's getMoviesList method failed.")
            }
        }
    }
    
    func testLoadingMoviesListWithNextPageResultsAppended() {
        
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), self.getMockJSON().toJSONData()!)
        }
        
        let expectation = XCTestExpectation(description: "response")
        model.movieApiReponse.page = 0
        model.getMoviesList { (result) in
            
            expectation.fulfill()
            XCTAssertTrue(self.model.movieApiReponse.movies.count == 1, "AYMovieListViewModel's getMoviesList method does not work as expected.")
        }
        
        wait(for: [expectation], timeout: 1)
        
        model.getMoviesList { (result) in
            expectation.fulfill()
            XCTAssertTrue(self.model.movieApiReponse.movies.count == 2, "AYMovieListViewModel's getMoviesList method does not work as expected, it should append next page results")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoadingMoviesListWithFailure() {
      
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!, Data())
        }
        
        let expectation = XCTestExpectation(description: "response")
        model.movieApiReponse.page = 0
        model.getMoviesList { (result) in
            
            expectation.fulfill()
            
            switch result {
            case .success:
                XCTFail("AYMovieListViewModel's getMoviesList method does not work as expected. It should return failure on api failure")
                
            case .failure:
                break;
            }
            
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
