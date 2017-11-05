//
//  PhotosTitleView.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/10/10.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit

private let photosTitleViewCellId = "photosTitleViewCellId"
protocol SmartAlbumsViewDelegate : class {
    // 根据相册类型检索相册数据
    func fetchAlbumByType(type:Int)
}

class SmartAlbumsView: UIView {

    // 委托
    weak var delegate:SmartAlbumsViewDelegate?
    
    // 智能相册数据
    var smartAlbums:[SmartAlbum]? {
        didSet {
            self.addSubview(smartAlbumTableView)
            self.smartAlbumTableView.reloadData()
        }
    }
    
    // 响应点击事件的view()
    lazy var tapView:UIView = {
        let tapView:UIView = UIView(frame: self.bounds)
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tableView(_:numberOfRowsInSection:))))
        return tapView
    }()
    
    // 相册表格
    lazy var smartAlbumTableView:UITableView = {
        let tableView:UITableView = UITableView(frame: CGRect(origin: CGPoint.init(x: 0, y: -60), size: CGSize(width: SCREEN_W, height: SCREEN_H)))
        tableView.register(UINib.init(nibName: "PhotosTitleViewCell", bundle: nil), forCellReuseIdentifier: photosTitleViewCellId)
        tableView.contentInset.top = 60
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.35)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SmartAlbumsView {
    
    // 显示当前view
    func toggleSmartAlbumsView(callBack:@escaping (_ y:CGFloat)->Void) {
        
        let tempHidden = !self.isHidden
        let y = tempHidden ? -SCREEN_H : (NAVIGATIONBAR_H + UIApplication.shared.statusBarFrame.height)
        // 显示菜单
        if y > 0 {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.isHidden = !self.isHidden
                self.frame.origin.y = (NAVIGATIONBAR_H + UIApplication.shared.statusBarFrame.height)
            }) { (finished) in
                self.frame.origin.y = y
                callBack(y)
            }
        } else {
            // 隐藏菜单
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.frame.origin.y += 8
            }, completion: { (isFinished) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin.y = y
                }, completion: { (isFinished) in
                    callBack(y)
                })
                
            })

        }
        
    }
    
}

extension SmartAlbumsView : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.smartAlbums?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = self.smartAlbums![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: photosTitleViewCellId) as! PhotosTitleViewCell
        cell.album = album
        return cell
    }
    
    // 根据数组数量改变点击tapView的Y值(给当前view添加手势，会造成cell的点击失效，所以另添加一个view来响应点击)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tapView.frame.origin.y = CGFloat(self.smartAlbums!.count) * 60
        self.addSubview(self.tapView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.smartAlbums![indexPath.row].albumType!
        delegate?.fetchAlbumByType(type: type)
    }

}
