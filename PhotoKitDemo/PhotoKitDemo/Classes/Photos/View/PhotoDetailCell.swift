//
//  PhotoDetailCell.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/10/28.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit

class PhotoDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var largeImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
