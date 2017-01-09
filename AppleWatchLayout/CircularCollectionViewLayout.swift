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
    
    override func prepare() {
        let x = collectionView!.frame.width / 2 - itemSize.width / 2
        let y = collectionView!.frame.height / 2 - itemSize.height / 2
        
        collectionView!.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
    
    override var collectionViewContentSize: CGSize {
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        let rowCount = row(forIndex: itemCount)
        let contentSize = CGSize(width: itemSize.width * CGFloat(numberOfItemsPerRow),
                                 height: itemSize.height * CGFloat(rowCount))
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = attributesForItem(atIndexPath: indexPath, contentOffset: collectionView!.contentOffset)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) ->  [UICollectionViewLayoutAttributes]? {
        let attributes = attributesForElements(in: rect, contentOffset: collectionView!.contentOffset)
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        var distance = CGFloat.greatestFiniteMagnitude
        
        let proposedRect = CGRect(origin: proposedContentOffset, size: collectionView!.bounds.size)
        let proposedCenterPoint = CGPoint(x: proposedRect.center.x, y: proposedRect.center.y)
        
        let attrs = attributesForElements(in: proposedRect, contentOffset: proposedContentOffset, isAdjustedLayuot: false)
        
        attrs?.forEach { attr in
            let newOffsetX = attr.frame.center.x - proposedCenterPoint.x
            let newOffsetY = attr.frame.center.y - proposedCenterPoint.y
            let newDistance = sqrt(newOffsetX * newOffsetX + newOffsetY * newOffsetY)
            
            if newDistance < distance  {
                distance = newDistance
                offsetY = newOffsetY
                offsetX = newOffsetX
            }

        }
        
        let targetOffset = CGPoint(x: proposedContentOffset.x + offsetX, y: proposedContentOffset.y + offsetY)
        return targetOffset
    }
    
    fileprivate func attributesForElements(in rect: CGRect, contentOffset: CGPoint, isAdjustedLayuot: Bool = true) ->  [UICollectionViewLayoutAttributes]? {
        let numberOfItems = collectionView!.numberOfItems(inSection: 0)
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        
        (0..<numberOfItems).forEach { index in
            let frame = initialFrameForItem(atIndex: index)
            if rect.intersects(frame) {
                let indexPath = IndexPath(item: index, section: 0)
                let attributes = attributesForItem(atIndexPath: indexPath, contentOffset: contentOffset, isAdjustedLayuot: isAdjustedLayuot)
                attributesArray.append(attributes)
            }
        }
        
        return attributesArray
    }
    
    fileprivate func attributesForItem(atIndexPath indexPath: IndexPath, contentOffset: CGPoint, isAdjustedLayuot: Bool = true) -> UICollectionViewLayoutAttributes {
        let frame = initialFrameForItem(atIndex: indexPath.item)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        if !isAdjustedLayuot {
            attributes.frame = frame
        } else {
            let attrs = adjustedAttributes(forFrame: frame, contentOffset: contentOffset)
            attributes.frame = attrs.0
            attributes.zIndex = attrs.1
        }
        
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
    
    fileprivate func adjustedAttributes(forFrame frame: CGRect, contentOffset: CGPoint) -> (CGRect, Int) {
        let halfWidth = collectionView!.frame.size.width / 2
        let halfHeight = collectionView!.frame.size.height / 2
        
        var frame = frame.offsetBy(dx: -contentOffset.x,
                                   dy: -contentOffset.y)
        frame = frameByOffsetingFromCenter(usingFrame: frame)
        
        let center = frame.center
        
        // normilize
        var x = center.x / halfWidth
        var y = center.y / halfHeight
        
        // guard to exclude frames outside of the `circle`
        let initialDistance = sqrt(x * x + y * y)
        guard initialDistance <= 1.0 else {
            return (CGRect.zero, 0)
        }
        
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
        var width = frame.width * scale
        var height = frame.height * scale
        width = width < 1.0 ? 1.0 : width
        height = height < 1.0 ? 1.0 : height
        
        frame = CGRect.rect(withCenter: CGPoint(x: x, y: y),
                            size: CGSize(width: width, height: height))
        frame = frame.offsetBy(point: contentOffset)
        
        let zIndex = -Int(((divisor - 2) / divisor) * 100)
        
        return (frame, zIndex)
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
