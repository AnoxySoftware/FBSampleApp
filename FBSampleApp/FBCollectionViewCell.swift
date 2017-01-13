//
//  FBCollectionViewCell.swift
//  FBSampleApp
//
//  Created by Eleftherios Charitou on 12/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//


import UIKit

class FBCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.borderColor = UIColor.customDarkGray().cgColor
        self.imageView.layer.borderWidth = 0.5
    }
    
}
