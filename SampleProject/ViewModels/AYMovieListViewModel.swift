//
//  AYMovieListViewModel.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation

struct AYMovieListCellViewModel {
    
    let title: String
    let imageUrl: String?
    let description: String
    
    init(with movieIteam: Movie) {
        
        self.title = movieIteam.title ?? ""
        
        if let imageUrl = movieIteam.posterPath  {
            
            let imageURL = kBaseImageURLPath + imageUrl
            self.imageUrl = imageURL
        } else {
            self.imageUrl = nil
        }
        
        self.description = movieIteam.overview ?? ""
    }
}


class AYMovieListViewModel {
    
    var movieApiReponse = MovieApiResponse()

    func getListCellViewModel(at indexPath: IndexPath) -> AYMovieListCellViewModel {
        return AYMovieListCellViewModel(with: movieApiReponse.movies[indexPath.item])
    }
    
    func getMoviesList(result: @escaping (Result<String>)-> Void) {

        let nextPage = movieApiReponse.page != nil ? movieApiReponse.page! + 1 : 1
        let dataLoader = APIRequestLoader(apiRequest: MovieListRequest())
        dataLoader.loadAPIRequest(requestData: "\(nextPage)") { [weak self] (apiResponse, error) in
            
            if let response = apiResponse {
                self?.movieApiReponse.addResults(from: response)
                result(.success)
            }
            else {
                result(.failure(error.debugDescription))
            }
        }
    }
}
