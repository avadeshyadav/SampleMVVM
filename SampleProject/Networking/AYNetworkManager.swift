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
let kMovieAPIKey: String = "7a312711d0d45c9da658b9206f3851dd"
let kMovieAPIServer: String = "https://api.themoviedb.org"


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

enum WaitForNetwork: Int {
    case started, ended
}

typealias WaitingForNetworkBlock = (_ waitngForNetwork: WaitForNetwork) -> Void

class APIRequestLoader<T: APIRequest>: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
  
    let apiRequest: T
    var urlSession: URLSession?
    
    private var task: URLSessionDataTask?
    private var apiCompletionBlock: ((T.ResponseDataType?, Error?) -> Void)?
    private var networkWaitingBlock: WaitingForNetworkBlock?
    private var data: Data?
    
    deinit {
        urlSession?.finishTasksAndInvalidate()
        doCleanUp()
    }
    
    init(apiRequest: T, urlSession: URLSession? = nil) {
        self.apiRequest = apiRequest
        super.init()

        if let session = urlSession {
            self.urlSession = session
        }
        else {
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.current)
        }
    }
    
    func setNetworkWaitingBlock(_ block: WaitingForNetworkBlock?) {
        networkWaitingBlock = block
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
            
            apiCompletionBlock = completionHandler
            task = urlSession?.dataTask(with: urlRequest)
            task?.resume()
        }
        catch {
            print("unable to create request")
        }
    }
    
    func cancelTask()  {
        task?.cancel()
        task = nil
        self.doCleanUp()
    }
    
    //MARK: URLSessionDelegate Methods
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        completionHandler(.allow)
        self.networkWaitingBlock?(.ended)
        data = Data()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data?.append(data)
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        self.networkWaitingBlock?(.started)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        
        //defer {
//            self.doCleanUp()
        //}
        
        //        AYNetworkLogger.log(response: response, data: data, error: error, forRequest: urlRequest)
        guard let data = self.data else {
            DispatchQueue.main.async {
                self.apiCompletionBlock?(nil, error)
                self.doCleanUp()
            }
            return
        }
        
        if self.apiRequest.shouldCacheResponse() { self.cacheData(data: data, forRequest: task.originalRequest) }
        
        do {
            let parsedResponse = try self.apiRequest.parseResponse(data: data)
            DispatchQueue.main.async {
                self.apiCompletionBlock?(parsedResponse, nil)
                self.doCleanUp()
            }
        } catch {
            DispatchQueue.main.async {
                self.apiCompletionBlock?(nil, error)
                self.doCleanUp()
            }
        }
    }
    
    func doCleanUp() {
        self.apiCompletionBlock = nil
        self.networkWaitingBlock = nil
        self.data = nil
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
