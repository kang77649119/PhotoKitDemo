//
//  PhotoDetailVC.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/10/28.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit
import Photos

private let photoDetailCellId = "photoDetailCellId"
class PhotoDetailVC: UIViewController {
    
    // 上一个界面点击的cell的索引
    var indexPath:IndexPath!
    
    // 上一个界面选中的cell
    var selectedCell:PhotoCell?
    
    // 右侧下一步按钮
    lazy var rightBtn:UIBarButtonItem = {
        
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 10)))
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 11)
        button.backgroundColor = UIColor.orange
        let rightBarButtonItem = UIBarButtonItem(customView: button)
        return rightBarButtonItem
        
    }()
    
    // 胶卷数据
    var assetResultsArray:[PHAsset]? {
        didSet {
            self.navigationItem.title = "\(indexPath.item + 1)/\(assetResultsArray!.count)"
            self.navigationItem.rightBarButtonItem = rightBtn
            self.photosCollectionView.reloadData()
        }
    }
 
    // cell尺寸
    let cellRect:CGRect = CGRect(x: 0, y: 0, width: SCREEN_W, height: SCREEN_H - (NAVIGATIONBAR_H + STATUSBAR_H))
    
    // 转场动画使用的参数
    lazy var detailCell:PhotoDetailCell = {
        return PhotoDetailCell(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: SCREEN_W, height: SCREEN_H - (NAVIGATIONBAR_H + STATUSBAR_H))))
    }()
    
    // 图片浏览器
    lazy var photosCollectionView:UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = cellRect.size
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        let collectionView:UICollectionView = UICollectionView(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: SCREEN_W, height: SCREEN_H)) , collectionViewLayout: flowLayout)
        collectionView.register(UINib.init(nibName: "PhotoDetailCell", bundle: nil), forCellWithReuseIdentifier: photoDetailCellId)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
        
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 导航控制器转场委托
        self.navigationController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension PhotoDetailVC {
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(photosCollectionView)
    }
    
}

extension PhotoDetailVC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetResultsArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoDetailCellId, for: indexPath) as! PhotoDetailCell
        
        let asset = self.assetResultsArray![indexPath.item]
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        option.resizeMode = .exact
        
        PHCachingImageManager().requestImage(for: asset, targetSize: collectionView.bounds.size, contentMode: PHImageContentMode.aspectFit, options: option) { (image, dicts) in
            cell.largeImageView.image = image
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / SCREEN_W) + 1
        self.navigationItem.title = "\(index)/\(self.assetResultsArray!.count)"
    }
    
}

extension PhotoDetailVC : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return operation == .push ? PhotoDetailAnimation(.PUSH) : PhotoDetailAnimation(.POP)
    }
    
}
















