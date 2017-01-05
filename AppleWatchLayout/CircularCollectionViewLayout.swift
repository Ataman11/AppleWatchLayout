//
//  CircularCollectionViewLayout.swift
//  AppleWatchLayout
//
//  Created by new user on 2017-01-03.
//  Copyright © 2017 Artem Goryaev. All rights reserved.
//

import UIKit

class CircularCollectionViewLayout: UICollectionViewLayout {
    
    public var itemSize: CGSize = CGSize(width: 50, height: 50)
    public var numberOfItemsPerRow: Int = 20
    
    override var collectionViewContentSize: CGSize {
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        let rowCount = row(forIndex: itemCount - 1)
        let contentSize = CGSize(width: itemSize.width * CGFloat(numberOfItemsPerRow),
                                 height: itemSize.height * CGFloat(rowCount))
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = attributesForItem(atIndexPath: indexPath)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) ->  [UICollectionViewLayoutAttributes]? {
        let numberOfItems = collectionView!.numberOfItems(inSection: 0)
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        
        (0..<numberOfItems).forEach { index in
            let frame = initialFrameForItem(atIndex: index)
            if rect.intersects(frame) {
                let indexPath = IndexPath(item: index, section: 0)
                let attributes = attributesForItem(atIndexPath: indexPath)
                attributesArray.append(attributes)
            }
        }
        
        return attributesArray
    }
    
    fileprivate func attributesForItem(atIndexPath indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let frame = initialFrameForItem(atIndex: indexPath.item)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        let attrs = adjustedAttributes(forFrame: frame)
        attributes.frame = attrs.0
        attributes.zIndex = attrs.1
        attributes.size = attrs.0.size
        
        return attributes
    }
    
    fileprivate func initialFrameForItem(atIndex index: Int) -> CGRect {
        let aRow = row(forIndex: index)
        let column = index - aRow * numberOfItemsPerRow
        let x = CGFloat(column) * itemSize.width
        let y = CGFloat(aRow) * itemSize.height

        return CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
    }
    
    fileprivate func row(forIndex index: Int) -> Int {
        return index / numberOfItemsPerRow
    }
    
    fileprivate func adjustedAttributes(forFrame frame: CGRect) -> (CGRect, Int) {
        let halfWidth = collectionView!.frame.size.width / 2
        let halfHeight = collectionView!.frame.size.height / 2
        
        var frame = frameWithoutContentOffset(usingFrame: frame)
        
        guard frame.origin.x <= halfWidth * 2
            && frame.origin.y <= halfHeight * 2
            && frame.origin.x >= 0
            && frame.origin.y >= 0 else {
                
                return (CGRect.zero, 0)
        }
        
        frame = frameByOffsetingFromCenter(usingFrame: frame)
        let center = frame.center
        
        // normilize
        var x = center.x / halfWidth
        var y = center.y / halfHeight
        
        // spherical projection - https://en.wikipedia.org/wiki/Stereographic_projection
        let divisor = 1 + x * x + y * y
        x  = (2 * x / divisor)
        y = (2 * y / divisor)
        let distanceFromCenter: CGFloat = sqrt(x * x + y * y)
        
        // back to the orginal scale
        x = x * halfWidth + halfWidth
        y = y * halfHeight + halfHeight
        
        // adjust size based on distance from center
        var scale = 1.0 - pow(distanceFromCenter, 4)
        scale = scale * 1.3
        let width = frame.width * scale
        let height = frame.height * scale
        
        frame = CGRect.rect(withCenter: CGPoint(x: x, y: y),
                            size: CGSize(width: width, height: height))
        frame = frameWithContentOffset(usingFrame: frame)
        
        let zIndex = -Int(((divisor - 2) / divisor) * 100)
        
        return (frame, zIndex)
    }
    
    fileprivate func frameWithoutContentOffset(usingFrame frame: CGRect) -> CGRect {
        return frame.offsetBy(dx: -collectionView!.contentOffset.x,
                              dy: -collectionView!.contentOffset.y)
    }
    
    fileprivate func frameWithContentOffset(usingFrame frame: CGRect) -> CGRect {
        return frame.offsetBy(point: collectionView!.contentOffset)
    }
    
    fileprivate func frameByOffsetingFromCenter(usingFrame frame: CGRect) -> CGRect {
        let viewWidth = collectionView!.frame.width
        let viewHeight = collectionView!.frame.height
        let centerX = viewWidth / 2
        let centerY = viewHeight / 2
        
        return frame.offsetBy(dx: -centerX, dy: -centerY)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
