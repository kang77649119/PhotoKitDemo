//
//  PhotosVC.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/9/27.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit
import Photos

let MAX_SEL_PHOTOS_COUNT = 9
let SCREEN_W = UIScreen.main.bounds.width
let SCREEN_H = UIScreen.main.bounds.height
let NAVIGATIONBAR_H:CGFloat = 44
let STATUSBAR_H = UIApplication.shared.statusBarFrame.height
private let reuseIdentifier = "photoCell"

class PhotosVC: UIViewController {
    
    // 右侧下一步按钮
    lazy var rightBtn:UIButton = {
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 10)))
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 11)
        button.backgroundColor = UIColor.orange
        return button
    }()
    
    lazy var rightBarButtonItem:UIBarButtonItem = {
        let rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        return rightBarButtonItem
    }()
    
    // 相册容器
    lazy var photoCollection:UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 0.5
        layout.itemSize = CGSize(width: (SCREEN_W - 0.5 * 3) / 4, height: (SCREEN_W - 0.5 * 3) / 4)
        
        let collectionView:UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
        
    }()
    
    // 标题栏
    lazy var titleView:UIButton = {
        let font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 2))
        let textColor = UIColor.black
        let btn:UIButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 64)))
        btn.setTitle("相机胶卷", for: .normal)
        btn.titleLabel?.font = font
        btn.setTitleColor(textColor, for: .normal)
        btn.addTarget(self, action: #selector(self.showAlbums(sender:)), for: .touchUpInside)
        btn.setImage(UIImage.init(named: "jt_down"), for: .normal)
        btn.setImage(UIImage.init(named: "jt_down"), for: .highlighted)
        return btn
    }()

    // 统计的智能相册
    lazy var smartAlbumsView:SmartAlbumsView = {
        let smartAlbumsView = SmartAlbumsView(frame: CGRect(origin: CGPoint.init(x: 0, y: -SCREEN_H), size: CGSize(width: SCREEN_W, height: SCREEN_H)))
        smartAlbumsView.isHidden = true
        smartAlbumsView.delegate = self
        smartAlbumsView.tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideSmartView)))
        return smartAlbumsView
    }()
    
    // 已选照片数量
    var selectedCount:Int = 0 {
        didSet {
            if selectedCount > 0 {
                self.rightBtn.setTitle("下一步(\(selectedCount)", for: .normal)
            } else {
                self.rightBtn.setTitle("下一步", for: .normal)
            }
        }
    }
    
    // 胶卷数据
    var assetResultsArray:[PHAsset]?
    
    // 智能相册统计
    var smartAlbumsArray:[SmartAlbum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        setupUI()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension PhotosVC {
    
    // 初始化
    func setupUI() {
        
        // 注册相册监听
        PHPhotoLibrary.shared().register(self)
        
        // 添加collectionView
        self.photoCollection.backgroundColor = .white
        self.view.addSubview(self.photoCollection)
        
        // 授权
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            print("已授权")
            // 获取相册数据(图片+视频)
            initData()
        case .denied:
            print("拒绝授权")
        case .notDetermined:
            print("未授权", Thread.current)
            PHPhotoLibrary.requestAuthorization({ (status) in
                print("授权处理", Thread.current)
                if status == .authorized {
                    print("授权....")
                    DispatchQueue.main.sync {
                        print("self.initData...",Thread.current)
                        self.initData()
                    }
                }
            })
        default:
            print("其他情况")
        }
    }
    
    // 初始化界面数据
    func initData() {
        
        // 初始化titleView
        self.navigationItem.titleView = titleView
        
        // 下一步按钮
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // 加载胶卷相册数据
        loadPictures()
        
        // 统计智能相册数据
        loadSmartAlbums()
        
        // 单独请求图片和视频的方式如下：
        // 单独请求图片时可以设置时间排序 options.sortDescriptors = [ NSSortDescriptor.init(key: "creationDate", ascending: true) ]
        //        // 图片
        //        let imageAssetResults = PHAsset.fetchAssets(with: .image, options: options)
        //        imageAssetResults.enumerateObjects { (asset, index, stop) in
        //            self.assetResults!.append(asset)
        //        }
        //
        //        // 视频
        //        let videoAssetResults = PHAsset.fetchAssets(with: .video, options: options)
        //        videoAssetResults.enumerateObjects { (asset, index, stop) in
        //            self.assetResults!.append(asset)
        //        }
        
    }
    
    // 统计智能相册数据
    func loadSmartAlbums() {
        
        var smartAlbum:SmartAlbum!
        self.smartAlbumsArray = []
        let smartCollectionResults = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smartCollectionResults.enumerateObjects { (collection, index, stop) in
            let fetchResults = PHAsset.fetchAssets(in: collection, options: nil)
            if fetchResults.count > 0 {
                PHImageManager().requestImage(for: fetchResults.lastObject!, targetSize: PhotoCell.fetchImageSize, contentMode: .aspectFill, options: PhotoCell.imagePHOption, resultHandler: { (image, info) in
                    
                    smartAlbum = SmartAlbum()
                    smartAlbum.pictureCount = fetchResults.count
                    smartAlbum.albumTitle = collection.localizedTitle!
                    smartAlbum.albumType = collection.assetCollectionSubtype.rawValue
                    smartAlbum.coverPhotoImage = image
                    self.smartAlbumsArray.append(smartAlbum)
                    
                })
            }
        }

        if !self.smartAlbumsArray.isEmpty {
            self.smartAlbumsView.smartAlbums = self.smartAlbumsArray
            self.view.addSubview(self.smartAlbumsView)
        }
        
    }

    
    // 加载相册数据
    func loadPictures() {
        
        print("开始取照片...")
        assetResultsArray = []

        // 设置查询参数 - 如果是获取胶卷中的数据，不能够设置时间排序
        // let options = PHFetchOptions()

        // 从胶卷中获取所有的内容(图片及视频)
        let list = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        list.enumerateObjects { (collection, index, stop) in
            let assetResults = PHAsset.fetchAssets(in: collection, options: nil)
            assetResults.enumerateObjects({ (asset, index, stop) in
                self.assetResultsArray!.append(asset)
            })
            self.assetResultsArray!.sort(by: { (asset1, asset2) -> Bool in
                return asset1.creationDate! < asset2.creationDate!
            })
        }

        /**
         缓存图片
         targetSize：图片尺寸的定义，封装到cell属性中，后面会用到
         options：   图片传递方式的定义，封装到cell属性中，后面会用到
         **/
        PHCachingImageManager().startCachingImages(for: self.assetResultsArray!, targetSize: PhotoCell.fetchImageSize, contentMode: .aspectFill, options: PhotoCell.imagePHOption)
        
        // 刷新collectionView
        self.photoCollection.reloadData()
        
    }
    
    // 切换显示智能相册列表
    @objc func showAlbums(sender:UIButton) {
        toggleSmartAlbumsViewHelper()
    }
    
    // 隐藏智能相册列表
    @objc func hideSmartView() {
        toggleSmartAlbumsViewHelper()
    }
    
    // 显示或隐藏智能相册辅助方法
    private func toggleSmartAlbumsViewHelper() {
        
        self.smartAlbumsView.toggleSmartAlbumsView { (y) in
            let isHidden = y > 0 ? false : true
            self.smartAlbumsView.isHidden = isHidden
            let imgName = isHidden ? "jt_down" : "jt_up"
            self.titleView.setImage(UIImage.init(named: imgName), for: .normal)
            self.titleView.setImage(UIImage.init(named: imgName), for: .highlighted)
            self.navigationItem.titleView = self.titleView
        }

    }
    
}

extension PhotosVC : SmartAlbumsViewDelegate {
    
    // 根据相册类型获取相册
    func loadAlbumsByType(type:Int? = nil) {
    
        // 标题
        var title:String = ""
        
        assetResultsArray = []
        let smartCollectionResults = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smartCollectionResults.enumerateObjects { (collection, index, stop) in
            // 根据相册类型获取数据
            if collection.assetCollectionSubtype.rawValue == type {
                title = collection.localizedTitle!
                let fetchResults = PHAsset.fetchAssets(in: collection, options: nil)
                if fetchResults.count > 0 {
                    fetchResults.enumerateObjects({ (asset, index, stop) in
                        self.assetResultsArray!.append(asset)
                    })
                }
            }
        }
        
        // 刷新collectionView
        DispatchQueue.main.async {
            self.photoCollection.reloadData()
            self.showAlbums(sender: UIButton())
            self.titleView.setTitle(title, for: .normal)
        }
    }
    
    // 根据相册类型，检索相册数据
    func fetchAlbumByType(type: Int) {
        loadAlbumsByType(type: type)
    }
    
}

extension PhotosVC : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            initData()
        }
    }
}

extension PhotosVC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetResultsArray?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.asset = self.assetResultsArray![indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoDetailVC = PhotoDetailVC()
        photoDetailVC.selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoCell
        photoDetailVC.indexPath = indexPath
        photoDetailVC.assetResultsArray = self.assetResultsArray
        self.navigationController?.delegate = photoDetailVC
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
        
    }
    
}

extension PhotosVC : PhotoCellImageChooseDelegate {
    
    // 选择图片
    func chooseImage(addCount: Int) {
        self.selectedCount += addCount
    }
    
    
}

















