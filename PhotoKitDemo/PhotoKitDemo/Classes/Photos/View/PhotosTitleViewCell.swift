//
//  PhotosTitleViewCell.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/10/10.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit

class PhotosTitleViewCell: UITableViewCell {
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    @IBOutlet weak var pictureCountLabel: UILabel!
    
    var album:SmartAlbum? {
        didSet {
            self.coverPhotoImageView.image = album!.coverPhotoImage
            self.albumTitleLabel.text = album!.albumTitle
            self.pictureCountLabel.text = "\(album!.pictureCount)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
