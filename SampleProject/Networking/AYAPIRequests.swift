//
//  AYAPIRequests.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation
import UIKit

class MovieListRequest: APIRequest {
    
    func makeRequest(from pageNumber: String) throws -> URLRequest {
        
        let params: [String: String] = ["page": pageNumber, "api_key": "7a312711d0d45c9da658b9206f3851dd"]
        let url = try? URLEncoder().urlWith(string: "https://api.themoviedb.org/3/discover/movie", parameters: params)
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
    
    func parseResponse(data: Data) throws -> MovieApiResponse {
        return try JSONDecoder().decode(MovieApiResponse.self, from: data)
    }
}




class ImageRequest: APIRequest {
    
    func makeRequest(from imagePath: String) throws -> URLRequest {
        
        let url = try? URLEncoder().urlWith(string: "\(kBaseImageURLPath)\(imagePath)", parameters: nil)
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
    
    func parseResponse(data: Data) throws -> UIImage {
        return UIImage(data: data) ?? UIImage()
    }
    
    func shouldCacheResponse() -> Bool {
        return true
    }
}
