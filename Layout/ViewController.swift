//
//  ViewController.swift
//  Layout
//
//  Created by Dennis Oberhoff on 30.09.17.
//  Copyright © 2017 Dennis Oberhoff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let totalCells = 0
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeadingAlignedLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    lazy private var values: [String] = {
        return (0...1000).map {
            _ in
            switch arc4random_uniform(3) {
            case 0: return "Hello"
            case 1: return "Hello, Goodbye"
            default: return "Hello, Goodbye, Hello Again!"
            }
        }
    }()
    
}

extension ViewController : UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TextCell
        cell.label.text = values[indexPath.row]
        return cell
    }
}
