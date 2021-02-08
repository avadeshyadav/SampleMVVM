//
//  AYUrlEncoder.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 30/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation

enum URLEncodingError: Swift.Error {
    case URLStringNotURLConvertible
}

protocol URLEncodeble {
    func encodedParams(_ parameters: Dictionary<String, Any>?) throws -> URL
}

enum APIVersion: String {
    case v1 = "/1"
    case v2 = "/2"
    case v3 = "/3"
    case none = ""
}

protocol APIURLBuildable {
    func apiVersion() -> APIVersion
    func hostServer() -> String
    func endPoint() -> String
}

extension APIURLBuildable {
    func hostServer() -> String { return kMovieAPIServer }
    func apiVersion() -> APIVersion { return .none }
    func endPoint() -> String { return "" }
}

class URLEncoder: URLEncodeble {
    
    var urlComponents: URLComponents?
    
    init(with urlBuildable: APIURLBuildable) {
        
        var url: String = urlBuildable.hostServer()
        url.append(urlBuildable.apiVersion().rawValue)
        url.append(urlBuildable.endPoint())
        urlComponents =  URLComponents(string: url)
    }
    
    func encodedParams(_ parameters: Dictionary<String, Any>?) throws -> URL {
        
        guard var urlComponents = self.urlComponents else {
            throw URLEncodingError.URLStringNotURLConvertible
        }
        
        guard let params = parameters else {
            return urlComponents.url!
        }
        
        let items = params.map {
            URLQueryItem(name: String(describing: $0), value: String(describing: $1)) }
        
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = Array<URLQueryItem>()
        }
        
        urlComponents.queryItems?.append(contentsOf: items)
        
        return urlComponents.url!
    }
}
