//
//  SimpleCollectionViewDataSource.swift
//  FBSampleApp
//
//  Created by Eleftherios Charitou on 13/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit

class SimpleCollectionViewDataSource<Cell: AnyObject, Object>: NSObject, UICollectionViewDataSource {
    
    var objects: [[Object]]
    fileprivate let configureCell: ConfigureCellBlock
    fileprivate var cellIdentifier: String
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
        return objects[indexPath.section][indexPath.row]
    }
    
    typealias ConfigureCellBlock = (Cell, Object) -> Void
    
    init(objects: [[Object]], cellIdentifier:String, configureCell: @escaping ConfigureCellBlock) {
        self.objects = objects
        self.configureCell = configureCell
        self.cellIdentifier = cellIdentifier
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:self.cellIdentifier, for: indexPath)
        configureCell(cell as! Cell, objectAtIndexPath(indexPath))
        return cell
    }
}
