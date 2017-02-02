//
//  CollectionViewController.swift
//  AppleWatchLayout
//
//  Created by new user on 2017-01-10.
//  Copyright © 2017 Artem Goryaev. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {
    
    fileprivate struct Constants {
        static let cellIdentifier = "AppleWatchCollectionViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: Constants.cellIdentifier, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: Constants.cellIdentifier)
        automaticallyAdjustsScrollViewInsets = true
        
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }

}

// MARK: - UICollectionViewDataSource

extension CollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let column = indexPath.row / numberOfItemsPerRow()
        let color = UIColor(red: CGFloat(sin(Float(column))),
                            green: CGFloat(cos(Float(column))),
                            blue: CGFloat(tan(Float(column))),
                            alpha: 1.0)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath)
        
        cell.backgroundColor = color
        
        return cell
    }
    
    fileprivate func numberOfItemsPerRow() -> Int {
        if let layout = collectionView?.collectionViewLayout as? CircularCollectionViewLayout {
            return layout.numberOfItemsPerRow
        }
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let layout = FullPageCollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        let vc = UICollectionViewController(collectionViewLayout: layout)
        vc.useLayoutToLayoutNavigationTransitions = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
