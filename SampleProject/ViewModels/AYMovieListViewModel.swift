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
    var isLoadingNextPageResults: Bool = false
    var isUserRefreshingList: Bool = false
    let apiLoader: APIRequestLoader<MovieListRequest>

    init(_ loader: APIRequestLoader<MovieListRequest> = APIRequestLoader(apiRequest: MovieListRequest())) {
        apiLoader = loader
    }
    
    func canLoadNextPage() -> Bool {
        
        if isLoadingNextPageResults || isUserRefreshingList { return false }
        
        if let currentPage = movieApiReponse.page, let totalPages = movieApiReponse.numberOfPages, currentPage + 1 > totalPages {
            return false
        }
        
        return true
    }
    
    func getListCellViewModel(at indexPath: IndexPath) -> AYMovieListCellViewModel {
        return AYMovieListCellViewModel(with: movieApiReponse.movies[indexPath.item])
    }
    
    func getMoviesList(result: @escaping (Result<String>)-> Void, networkWaitBlock: WaitingForNetworkBlock?) {

        let page = isUserRefreshingList ? 1 : (movieApiReponse.page ?? 0) + 1
        apiLoader.setNetworkWaitingBlock(networkWaitBlock)
        apiLoader.loadAPIRequest(requestData: "\(page)") { [weak self] (apiResponse, error) in
            
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
