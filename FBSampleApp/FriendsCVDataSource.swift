//
//  FriendsCVDataSource.swift
//  FBSampleApp
//
//  Created by Eleftherios Charitou on 13/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit
import Kingfisher

class FriendsCVDataSource: NSObject,UICollectionViewDataSource {
    
    typealias ConfigureCell = (FBCollectionViewCell, FBUser) -> Void
    
    var friends: [FBUser]
    
    fileprivate var cellIdentifier: String
    fileprivate let configureCell: ConfigureCell
    
    
    init(friends:[FBUser], cellIdentifier:String, configureCell: @escaping ConfigureCell) {
        self.friends = friends
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> FBUser {
        return friends[indexPath.row]
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:self.cellIdentifier, for: indexPath)
        configureCell(cell as! FBCollectionViewCell, objectAtIndexPath(indexPath))
        return cell
    }
}
