//
//  ViewController.swift
//  AppleWatchLayout
//
//  Created by new user on 2016-12-30.
//  Copyright © 2016 Artem Goryaev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate struct Constants {
        static let cellIdentifier = "AppleWatchCollectionViewCell"
    }
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: Constants.cellIdentifier, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: Constants.cellIdentifier)
        automaticallyAdjustsScrollViewInsets = false
        
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast

        segmentedControlValueChanged(self)
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        var layout: UICollectionViewLayout = UICollectionViewFlowLayout()
        
        switch segmentedControl.selectedSegmentIndex {
        // Flow
        case 0:
            layout = UICollectionViewFlowLayout()
        // Flow Subclass
        case 1:
            layout = CircularCollectionViewFlowLayout()
        // Custom
        case 2:
            layout = CircularCollectionViewLayout()
        default:
            break
        }
        
        if let layout = layout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = 0.0
            layout.sectionInset = .zero
            let side = collectionView.frame.width / 5
            layout.itemSize = CGSize(width: side, height: side)
        } else if let layout = layout as? CircularCollectionViewLayout {
            let side = collectionView.frame.width / 5
            layout.itemSize = CGSize(width: side, height: side)
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
    }

}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = layout.itemSize.width
            let leftInset = layout.sectionInset.left
            let rightInset = layout.sectionInset.right
            let spacing = layout.minimumInteritemSpacing
            
            let viewWidth = collectionView.frame.size.width - leftInset - rightInset
            let numberOfItems: CGFloat = viewWidth / (itemWidth + spacing)
            
            return Int(numberOfItems)
            
        } else if let layout = collectionView.collectionViewLayout as? CircularCollectionViewLayout {
            return layout.numberOfItemsPerRow
        }

        
        return 1
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
}

extension ViewController: UIScrollViewDelegate {
    
}

