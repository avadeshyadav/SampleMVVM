//
//  NetworkManager.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation

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

protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType
    func makeRequest(from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResponseDataType
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
            let task = urlSession.dataTask(with: urlRequest) { data, response, error in
              
                AYNetworkLogger.log(response: response, data: data, error: error, forRequest: urlRequest)
                guard let data = data else { return completionHandler(nil, error) }
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


