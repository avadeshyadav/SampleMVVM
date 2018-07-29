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
    func urlWith(string: String, parameters: Dictionary<String, Any>?) throws -> URL
}

class URLEncoder: URLEncodeble {
    
    func urlWith(string: String, parameters: Dictionary<String, Any>?) throws -> URL {
        
        guard var urlComponents = URLComponents(string: string) else {
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
