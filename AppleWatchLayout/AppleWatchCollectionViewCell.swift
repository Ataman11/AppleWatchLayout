//
//  AppleWatchCollectionViewCell.swift
//  AppleWatchLayout
//
//  Created by new user on 2016-12-30.
//  Copyright © 2016 Artem Goryaev. All rights reserved.
//

import UIKit

class AppleWatchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
    }

}
