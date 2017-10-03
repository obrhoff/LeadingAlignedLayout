//
//  TextCell.swift
//  TextCell
//
//  Created by Dennis Oberhoff on 01.10.17.
//  Copyright © 2017 Dennis Oberhoff. All rights reserved.
//

import UIKit

public class TextCell: UICollectionViewCell {
    
    public let label = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        backgroundColor = UIColor.orange
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ]
        constraints.forEach({ $0.priority = .defaultLow })
        NSLayoutConstraint.activate(constraints)
    }
}
