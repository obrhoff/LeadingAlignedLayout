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
    
    public override func prepare() {
        super.prepare()
        calculateAttributes(preferredAttributes: nil)
    }
    
    private func calculateAttributes(preferredAttributes: UICollectionViewLayoutAttributes?) {
        
        guard let collectionView = collectionView, collectionView.bounds.isEmpty == false else {
            return
        }
        
        var lastAttribute : UICollectionViewLayoutAttributes?
        let collectionFrame = collectionView.bounds.insetBy(dx: margins, dy: margins)
        let maxX = collectionFrame.maxX
        let minX = collectionFrame.minX
        let sectionsTotal = collectionView.numberOfSections
        
        for sectionIndex in 0..<sectionsTotal {
            let rows = collectionView.numberOfItems(inSection: sectionIndex)
            for rowIndex in 0..<rows {
                let currentPath = IndexPath(row: rowIndex, section: sectionIndex)
                let attributes = cache[currentPath] ?? UICollectionViewLayoutAttributes(forCellWith: currentPath)
                
                defer {
                    lastAttribute = attributes
                }
                
                if let sizedPath = preferredAttributes?.indexPath, sizedPath.compare(currentPath) == .orderedDescending {
                    continue
                }
                
                let lastFrame = lastAttribute?.frame ?? .zero
                var nextLeftFrame = lastFrame.offsetBy(dx: lastFrame.width + spacing, dy: 0)
                var nextBellowFrame = CGRect(x: minX, y: lastFrame.maxY + spacing, width: 0, height: 0)
                
                let size = preferredAttributes?.size ?? attributes.size
                nextBellowFrame.size = size
                nextLeftFrame.size = size
                
                let finalFrame = maxX > nextLeftFrame.maxX ? nextLeftFrame : nextBellowFrame
                attributes.frame = finalFrame
                cache[currentPath] = attributes
            }
        }
    }
    
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = cache[indexPath]
        return attribute
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
    }
    
    override  func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                       withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        
        let oldContentSize = collectionViewContentSize
        let invalidPaths = cache.keys.filter({
            ($0.section > originalAttributes.indexPath.section) ||
            ($0.section == originalAttributes.indexPath.section && $0.row >= originalAttributes.indexPath.row)
        })

        calculateAttributes(preferredAttributes: preferredAttributes)
        
        let newContentSize = collectionViewContentSize
        context.contentSizeAdjustment = CGSize(width: 0, height: newContentSize.height - oldContentSize.height)
        context.invalidateItems(at: invalidPaths)
        return context
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let invalidate = !(newBounds.width == collectionView?.bounds.width)
        return invalidate
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override var collectionViewContentSize: CGSize {
        let height = cache.max { a, b in a.value.frame.maxY < b.value.frame.maxY }?.value.frame.maxY ?? 0.0
        let width = collectionView?.bounds.width ?? 0.0
        return CGSize(width: width, height: height)
    }
    
    open override class var invalidationContextClass: AnyClass {
        return LeadingAlignedLayoutInvalidationContext.self
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
    
    public var estimatedSize : CGSize = CGSize(width: 50, height: 50) {
        didSet {
            invalidateLayout()
        }
    }
}

private class LeadingAlignedLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext {
    override var invalidateEverything: Bool {
        return false
    }
}
