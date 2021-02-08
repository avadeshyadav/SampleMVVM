//
//  AYAPIRequests.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation
import UIKit

class MovieListRequest: APIRequest, APIURLBuildable {
    
    func makeRequest(from pageNumber: String) throws -> URLRequest {
        
        let url = try? URLEncoder(with: self).encodedParams(["page": pageNumber, "api_key": kMovieAPIKey])
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
    
    func apiVersion() -> APIVersion {
        return .v3
    }
    
    func endPoint() -> String {
        return "/discover/movie"
    }
    
    func parseResponse(data: Data) throws -> MovieApiResponse {
        return try JSONDecoder().decode(MovieApiResponse.self, from: data)
    }
}


class ImageRequest: APIRequest {
    
    func makeRequest(from imagePath: String) throws -> URLRequest {
        
        let urlRequest = URLRequest(url: URL(string: imagePath)!)
        return urlRequest
    }
    
    func parseResponse(data: Data) throws -> UIImage {
        return UIImage(data: data) ?? UIImage()
    }
    
    func shouldCacheResponse() -> Bool {
        return true
    }
}
