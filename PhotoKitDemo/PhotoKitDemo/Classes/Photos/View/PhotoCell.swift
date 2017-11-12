//
//  PhotoCell.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/9/27.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit
import Photos

protocol PhotoCellImageChooseDelegate {
    // 选择图片
    func chooseImage(addCount:Int)
}

class PhotoCell: UICollectionViewCell {
    
    // 委托
    var delegate:PhotoCellImageChooseDelegate?
    
    // 视频时长
    var timeLabel:UILabel?
    
    // 选择图片按钮
    lazy var selectBtn:UIButton = {
        let margin:CGFloat = 5
        let btnW:CGFloat = 30
        let circleImage = UIImage(named : "circle")
        let circleSelImage = UIImage(named : "circle_sel")
        let btn = UIButton(frame: CGRect(origin: CGPoint(x: self.bounds.size.width - btnW - margin , y: margin), size: CGSize(width: btnW, height: btnW)))
        btn.setImage(circleImage, for: .normal)
        btn.setImage(circleSelImage, for: .selected)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, btnW - circleImage!.size.width, btnW - circleImage!.size.height, 0)
        btn.addTarget(self, action: #selector(self.chooseImage(sender:)), for: .touchUpInside)
        return btn
    }()
    
    // 请求图片尺寸
    static var fetchImageSize:CGSize = {
        let imgWH = ((SCREEN_W - 0.5 * 3) / 4) * 3
        return CGSize(width: imgWH, height: imgWH)
    }()
    
    // 请求图片质量参数
    static var imagePHOption:PHImageRequestOptions = {
        let option = PHImageRequestOptions()
        // 同步
        option.isSynchronous = true
        // 传递模式
        option.deliveryMode = .fastFormat // 快速(图片非高清)
//        option.deliveryMode = .automatic // 随机
//        option.deliveryMode = .highQualityFormat // 高清
        // 重绘模式
        option.resizeMode = .fast  // 快速
//        option.resizeMode = .exact // 精准
//        option.resizeMode = .none  // 无尺寸限制
        return option
    }()
    
    // 图片view
    lazy var photoImageView:UIImageView = {
        let imageView:UIImageView = UIImageView(frame: self.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var photoModel:PhotoModel? {
        didSet {
            let asset = photoModel!.asset!
            PHCachingImageManager().requestImage(for: asset, targetSize: PhotoCell.fetchImageSize, contentMode: .aspectFit, options: PhotoCell.imagePHOption) { (image, info) in
                
                self.timeLabel?.isHidden = true
                if asset.mediaType.rawValue == 2 {
                    // 添加时间
                    let time = asset.duration.formatHourMinueSecond()
                    let dicts = [ NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight(rawValue: 1)) ]
                    let timeSize = NSString(string: time).size(withAttributes: dicts)
                    let timeLabelRect = CGRect(origin: CGPoint.init(x: self.bounds.size.width - 5 - timeSize.width, y: self.bounds.size.height - 5 - timeSize.height), size: timeSize)
                    self.timeLabel = UILabel(frame: timeLabelRect)
                    self.timeLabel!.text = time
                    self.timeLabel?.textColor = UIColor.white
                    self.timeLabel?.font = UIFont.systemFont(ofSize: 12)
                    self.timeLabel?.isHidden = false
                    self.photoImageView.addSubview(self.timeLabel!)
                }
                
                // 添加圆圈标识
                self.photoImageView.addSubview(self.selectBtn)
                self.photoImageView.image = image
                self.contentView.addSubview(self.photoImageView)
            }
        }
    }
    
    // 选择图片
    @objc func chooseImage(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        
        // 计算选中的数量
        let count = sender.isSelected ? 1 : -1
        delegate?.chooseImage(addCount: count)
        
        // 是否选中
        self.photoModel!.isSelected = sender.isSelected
        
    }
    
}
