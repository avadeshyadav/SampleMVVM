//
//  AYReusableCellHandler.swift
//  SampleProject
//
//  Created by Avadesh Kumar on 29/07/18.
//  Copyright © 2018 Avadesh Kumar. All rights reserved.
//

import Foundation
import UIKit


protocol CellReusable {
    static var reuseableIdentifier: String { get }
    static var nib: UINib? { get }
}

extension CellReusable {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib? {
        return nil
    }
}

extension UITableView {
    
    func registerCell<T: UITableViewCell>(_ cellType: T.Type) where T: CellReusable {
        
        let identifier = cellType.reuseableIdentifier
        
        if let nib = cellType.nib {
            self.register(nib, forCellReuseIdentifier: identifier)
        } else {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
    
    func dequeueCell<T: UITableViewCell>(atIndexPath: IndexPath) -> T where T: CellReusable {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseableIdentifier, for: atIndexPath) as? T else {
            fatalError("Cell not registered with identifier:\(T.reuseableIdentifier)")
        }
        
        return cell
    }
}

extension UICollectionView{
    
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: CellReusable {
        if let nib = T.nib {
            self.register(nib, forCellWithReuseIdentifier: T.reuseableIdentifier)
        } else {
            self.register(UINib(nibName: T.reuseableIdentifier, bundle: nil), forCellWithReuseIdentifier: T.reuseableIdentifier)
        }
    }

    func dequeueCell<T: UICollectionViewCell>(atIndexPath: IndexPath) -> T where T: CellReusable {
        
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseableIdentifier, for: atIndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseableIdentifier)")
        }
        
        return cell
    }
    
}
