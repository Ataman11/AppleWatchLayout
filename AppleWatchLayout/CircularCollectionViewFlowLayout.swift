//
//  CircularCollectionViewLayout.swift
//  AppleWatchLayout
//
//  Created by new user on 2016-12-30.
//  Copyright © 2016 Artem Goryaev. All rights reserved.
//

import UIKit

class CircularCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        let attrs = adjustedAttributes(forFrame: attributes!.frame)
        attributes?.frame = attrs.0
        attributes?.zIndex = attrs.1
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) ->  [UICollectionViewLayoutAttributes]? {
        let attributesArray = super.layoutAttributesForElements(in: rect)
        
        attributesArray?.forEach({
            let attrs = adjustedAttributes(forFrame: $0.frame)
            $0.frame = attrs.0
            $0.zIndex = attrs.1
        })
        
        
        return attributesArray
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

extension CGRect {
    
    public var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    public static func rect(withCenter center: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: center.x - size.width/2,
                      y: center.y - size.height/2,
                      width: size.width,
                      height: size.height)
    }
    
    public func offsetBy(point: CGPoint) -> CGRect {
        return offsetBy(dx: point.x, dy: point.y)
    }
    
}
