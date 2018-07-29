//
//  AYMovieListViewModel.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation


class AYMovieListViewModel {
    
    var movieApiReponse = MovieApiResponse()

    func getMoviesList(result: @escaping (Result<String>)-> Void) {

        let nextPage = movieApiReponse.page != nil ? movieApiReponse.page! + 1 : 1
        let dataLoader = APIRequestLoader(apiRequest: MovieRequest())
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