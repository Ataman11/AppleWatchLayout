//
//  FullPageCollectionViewFlowLayout.swift
//  AppleWatchLayout
//
//  Created by new user on 2017-01-12.
//  Copyright © 2017 Artem Goryaev. All rights reserved.
//

import UIKit

class FullPageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        collectionView!.contentInset = .zero
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        var offsetX: CGFloat = CGFloat.greatestFiniteMagnitude
        
        let proposedRect = CGRect(origin: proposedContentOffset, size: collectionView!.bounds.size)
        let proposedPoint = CGPoint(x: proposedRect.origin.x, y: proposedRect.origin.y)
        
        let attrs = layoutAttributesForElements(in: proposedRect)
        
        attrs?.forEach { attr in
            let newOffsetX = attr.frame.origin.x - proposedPoint.x
            
            if newOffsetX < offsetX  {
                offsetX = newOffsetX
            }
            
        }
        
        let targetOffset = CGPoint(x: proposedContentOffset.x + offsetX, y: proposedContentOffset.y)
        return targetOffset
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }

}
