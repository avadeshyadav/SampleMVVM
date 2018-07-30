//
//  AYMoviesListViewController.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 28/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import UIKit

class AYMoviesListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let model = AYMovieListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitialConfigurations()
        loadMovies()
    }
    
    private func doInitialConfigurations() {
        self.title = "Movies"
    }
    
    private func loadMovies() {
      
        model.getMoviesList { [weak self] (result) in
            
            switch (result) {
            case .success:
                self?.collectionView.reloadData()
                
            case .failure(let message):
                print("received error while fetching data: \(message)")
            }
        }
    }
}


extension AYMoviesListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.movieApiReponse.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AYMovieListCollectionCell = collectionView.dequeueCell(atIndexPath: indexPath)
        cell.backgroundColor = UIColor.lightGray
        
        let movie = model.movieApiReponse.movies[indexPath.item]
       
        if let path = movie.posterPath {
            
            let dataLoader = APIRequestLoader(apiRequest: ImageRequest())
            dataLoader.loadAPIRequest(requestData: path) { [weak cell] (apiResponse, error) in
                
                if let response = apiResponse {
                    cell?.imageView.image = response
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-44)/3 , height: (UIScreen.main.bounds.width/3)+20)
    }
}
