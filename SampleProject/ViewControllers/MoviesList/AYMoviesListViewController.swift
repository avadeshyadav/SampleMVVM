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
    @IBOutlet weak var constraintCollectionViewBottomMargin: NSLayoutConstraint!
    
    var refreshControl: UIRefreshControl?
    let model = AYMovieListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitialConfigurations()
        loadMovies()
    }
    
    private func doInitialConfigurations() {
        self.title = "Movies"
        configureRefreshControl(on: collectionView)
    }
    
    private func loadMovies() {
      
        model.getMoviesList { [weak self] (result) in
            
            self?.isLoadingNextPageResults(false)
            self?.refreshControl?.endRefreshing()

            switch (result) {
            case .success:
                self?.collectionView.reloadData()
                
            case .failure(let message):
                print("received error while fetching data: \(message)")
            }
        }
    }
}

//MARK: - ColectionView Delegate and data source handling
extension AYMoviesListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.movieApiReponse.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AYMovieListCollectionCell = collectionView.dequeueCell(atIndexPath: indexPath)
        cell.configureCell(with: model.getListCellViewModel(at: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-44)/3 , height: (UIScreen.main.bounds.width/3)+20)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard model.canLoadNextPage() else {
            return
        }
        
        let margin: CGFloat = 30
        let heightToLoadNextPage: CGFloat = scrollView.contentSize.height + margin
        let currentPosition: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if (currentPosition >= heightToLoadNextPage) {
            isLoadingNextPageResults(true)
            loadNextPageResults()
        }
        
    }
}

//MARK: - Pull to refresh functionality
extension AYMoviesListViewController {
   
    func configureRefreshControl(on collectionView: UICollectionView) {
      
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refershMovieList), for: .valueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionView.refreshControl = refreshControl
    }
    
    @objc func refershMovieList() {
        
        model.isUserRefreshingList = true
        refreshControl?.beginRefreshing()
        loadMovies()
    }
}

//MARK: - Lazy loading functionality

let kLoaderViewTag = 1011
let kLoaderViewHeight: CGFloat = 50

extension AYMoviesListViewController {
    
    func loadNextPageResults() {
        loadMovies()
    }
    
    func isLoadingNextPageResults(_ isLoading: Bool) {
        
        model.isLoadingNextPageResults = isLoading
        
        if isLoading {
            constraintCollectionViewBottomMargin.constant = kLoaderViewHeight
            addLoaderViewForNextResults()
            
        }
        else {
            
            self.constraintCollectionViewBottomMargin.constant = 0
            
            let view = self.view.viewWithTag(kLoaderViewTag)
            view?.removeFromSuperview()
        }
        
        self.view.layoutIfNeeded()
    }
    
    func addLoaderViewForNextResults() {
        let view = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - kLoaderViewHeight , width: self.view.frame.size.width, height: kLoaderViewHeight))
        view.backgroundColor = UIColor.lightGray
        view.tag = kLoaderViewTag
        
        let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicatorView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        indicatorView.startAnimating()
        indicatorView.color = UIColor.white
        indicatorView.isHidden = false
        view.addSubview(indicatorView)
        
        self.view.addSubview(view)
    }
}
