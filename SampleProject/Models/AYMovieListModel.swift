//
//  AYMovieListModel.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation

struct MovieApiResponse: Decodable {
    var page: Int? = 1
    var numberOfResults: Int? = 0
    var numberOfPages: Int? = 0
    var movies: [Movie] = []
    
    mutating func addResults(from newObject: MovieApiResponse) {
        
        if let newPage = newObject.page {
            
            self.page = newPage
            self.numberOfPages = newObject.numberOfPages
            movies.append(contentsOf: newObject.movies)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case numberOfResults = "total_results"
        case numberOfPages = "total_pages"
        case movies = "results"
    }
}

struct Movie: Decodable {
    
    var id: Int?
    var posterPath: String?
    var backdrop: String?
    var title: String?
    var releaseDate: String?
    var rating: Double?
    var overview: String?
    var language: String?
    var genere: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case backdrop = "backdrop_path"
        case title
        case releaseDate = "release_date"
        case rating = "vote_average"
        case overview
        case language = "original_language"
        case genere = "genere"
    }
}
