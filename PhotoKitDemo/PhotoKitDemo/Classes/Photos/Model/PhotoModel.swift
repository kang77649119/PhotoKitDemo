//
//  PhotoModel.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/11/5.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit
import Photos

class PhotoModel: NSObject {
    
    // 图片
    var asset:PHAsset?
    
    // 是否选中
    var isSelected:Bool = false
    
    init(asset:PHAsset) {
        self.asset = asset
    }
    
    
}
