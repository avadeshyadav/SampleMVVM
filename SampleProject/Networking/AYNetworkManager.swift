//
//  NetworkManager.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation
import UIKit

enum Result<String>{
    case success
    case failure(String)
}

class MovieRequest: APIRequest {
    
    typealias RequestDataType = String
    typealias ResponseDataType = MovieApiResponse

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
    
    typealias RequestDataType = String
    typealias ResponseDataType = UIImage
    
    func makeRequest(from imagePath: String) throws -> URLRequest {
        
        let url = try? URLEncoder().urlWith(string: "https://image.tmdb.org/t/p/w200\(imagePath)", parameters: nil)
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

protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType
    func makeRequest(from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResponseDataType
    func shouldCacheResponse() -> Bool
}

extension APIRequest {
    func shouldCacheResponse() -> Bool {
        return false
    }
}


class APIRequestLoader<T: APIRequest> {
  
    let apiRequest: T
    let urlSession: URLSession
    
    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }
    
    func loadAPIRequest(requestData: T.RequestDataType,
                        completionHandler: @escaping (T.ResponseDataType?, Error?) -> Void) {
        do {
            let urlRequest = try apiRequest.makeRequest(from: requestData)
            AYNetworkLogger.log(request: urlRequest)
            
            if let response = getCachedData(from: urlRequest) {
                completionHandler(response, nil)
                return
            }
            
            let task = urlSession.dataTask(with: urlRequest) { data, response, error in
              
                AYNetworkLogger.log(response: response, data: data, error: error, forRequest: urlRequest)
                guard let data = data else { return completionHandler(nil, error) }
                self.cacheData(data: data, forRequest: urlRequest)
               
                do {
                    let parsedResponse = try self.apiRequest.parseResponse(data: data)
                    DispatchQueue.main.async {
                        completionHandler(parsedResponse, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
            task.resume()
        }
        catch {
            print("unable to create request")        }
    }
}

//MARK: Cache functionality

let dataCache = NSCache<NSString, NSData>()

extension APIRequestLoader {
    
    func getCachedData(from request: URLRequest) -> T.ResponseDataType? {
      
        if let key = request.url?.absoluteString, let cachedData = dataCache.object(forKey: key as NSString) {
            return try? self.apiRequest.parseResponse(data: cachedData as Data)
        }
        
        return nil
    }
    
    func cacheData(data: Data, forRequest: URLRequest?) {
        if let key = forRequest?.url?.absoluteString {
            dataCache.setObject(data as NSData, forKey: key as NSString)
        }
    }
}




