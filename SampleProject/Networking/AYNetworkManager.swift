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

let kBaseImageURLPath: String = "https://image.tmdb.org/t/p/w200"

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
    var task: URLSessionDataTask?
    
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
            
            task = urlSession.dataTask(with: urlRequest) { data, response, error in
              
                AYNetworkLogger.log(response: response, data: data, error: error, forRequest: urlRequest)
                guard let data = data else {
                    DispatchQueue.main.async {  completionHandler(nil, error) }
                    return
                }
                
                if self.apiRequest.shouldCacheResponse() { self.cacheData(data: data, forRequest: urlRequest) }
               
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
            task?.resume()
        }
        catch {
            print("unable to create request")
        }
    }
    
    func cancelTask()  {
        task?.cancel()
        task = nil
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




