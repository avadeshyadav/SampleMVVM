//
//  AYMovieListCollectionCell.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import UIKit

class AYMovieListCollectionCell: UICollectionViewCell, CellReusable {
        
    @IBOutlet weak var imageView: UIImageView!
    let dataLoader = APIRequestLoader(apiRequest: ImageRequest())

    override func awakeFromNib() {
        super.awakeFromNib()
        doInitialConfigurations()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dataLoader.cancelTask()
    }
    
    //MARK: Public methods
    func configureCell(with viewModel: AYMovieListCellViewModel) {
        
        guard let imageUrlString = viewModel.imageUrl else {
            return
        }
        
        dataLoader.loadAPIRequest(requestData: imageUrlString) { [weak self] (apiResponse, error) in
            
            if let response = apiResponse {
                self?.imageView.image = response
            }
        }
    }
    
    //MARK: Private Methods
    func doInitialConfigurations() {

        self.backgroundColor = UIColor.white
        imageView.backgroundColor = UIColor.lightGray

        imageView.makeCornerRadiusWithValue(2.0, borderColor: UIColor.white)
        self.makeCornerRadiusWithValue(2.0, borderColor: UIColor.lightGray)
    }
}
