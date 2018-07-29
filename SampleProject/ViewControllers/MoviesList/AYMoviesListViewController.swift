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
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension AYMoviesListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AYMovieListCollectionCell = collectionView.dequeueCell(atIndexPath: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-44)/3 , height: (UIScreen.main.bounds.width/3)+20)
    }
}
