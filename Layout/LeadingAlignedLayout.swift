//
//  LeadingAlignedLayout.swift
//  LeadingAlignedLayout
//
//  Created by Dennis Oberhoff on 01.10.17.
//  Copyright © 2017 Dennis Oberhoff. All rights reserved.
//

import Foundation
import UIKit

class LeadingAlignedLayout : UICollectionViewLayout {
    
    private var cache = [IndexPath : UICollectionViewLayoutAttributes]()
    private var reuseCache = [IndexPath : UICollectionViewLayoutAttributes]()
    
    public override func prepare() {
        super.prepare()
        calculateAttributes(preferredAttributes: nil)
    }
    
    private func calculateAttributes(preferredAttributes: UICollectionViewLayoutAttributes?) {
        
        var lastFrame : CGRect = .zero
        let collectionFrame = collectionView?.bounds.insetBy(dx: margins, dy: margins) ?? .zero
        let maxX = collectionFrame.maxX
        let minX = collectionFrame.minX
        let sections = collectionView?.numberOfSections ?? 0
        
        for sectionIndex in 0..<sections {
            let rows = collectionView?.numberOfItems(inSection: sectionIndex) ?? 0
            for rowIndex in 0..<rows {
                let currentPath = IndexPath(row: rowIndex, section: sectionIndex)
                if let cachedAttribute = cache[currentPath] {
                    lastFrame = cachedAttribute.frame
                    continue
                }
                
                var nextLeftFrame = lastFrame.offsetBy(dx: lastFrame.width + spacing, dy: 0)
                var nextBellowFrame = CGRect(x: minX, y: lastFrame.maxY + spacing, width: 0, height: 0)
                
                let size = preferredAttributes?.size ?? estimatedSize
                nextBellowFrame.size = size
                nextLeftFrame.size = size
                
                let attributes = reuseCache[currentPath] ?? UICollectionViewLayoutAttributes(forCellWith: currentPath)
                attributes.frame = maxX > nextLeftFrame.maxX ? nextLeftFrame : nextBellowFrame
                cache[currentPath] = attributes
                reuseCache.removeValue(forKey: currentPath)
                lastFrame = attributes.frame
            }
        }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = cache.flatMap({
            return rect.intersects($0.value.frame) ? layoutAttributesForItem(at: $0.key) : nil
        })
        return attributes
    }
    
    open override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                              withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return true
        // this kinda breaks everything
        //  return cache[originalAttributes.indexPath]?.size != preferredAttributes.size
    }
    
    override  func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                       withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        
        let oldContentSize = self.collectionViewContentSize
        let invalidPaths = cache.keys.filter({
            ($0.section > originalAttributes.indexPath.section) ||
                ($0.section == originalAttributes.indexPath.section && $0.row >= originalAttributes.indexPath.row)
        })
        
        invalidPaths.forEach({
            reuseCache[$0] = cache[$0]
            cache.removeValue(forKey: $0)}
        )
        calculateAttributes(preferredAttributes: preferredAttributes)
        
        let newContentSize = self.collectionViewContentSize
        context.contentSizeAdjustment = CGSize(width: 0, height: newContentSize.height - oldContentSize.height)
        context.invalidateItems(at: invalidPaths)
        return context
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
    }
    
    override var collectionViewContentSize: CGSize {
        let height = cache.max { a, b in a.value.frame.maxY < b.value.frame.maxY }?.value.frame.maxY ?? 0.0
        let width = collectionView?.bounds.width ?? 0.0
        return CGSize(width: width, height: height)
    }
    
    public var spacing: CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    
    public var margins : CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    
    public var estimatedSize : CGSize = CGSize(width: 80, height: 40) {
        didSet {
            invalidateLayout()
        }
    }
}

