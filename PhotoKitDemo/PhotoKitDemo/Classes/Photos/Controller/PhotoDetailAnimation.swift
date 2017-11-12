//
//  PhotoDetailAnimation.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/10/28.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit

class PhotoDetailAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Operate {
        case PUSH
        case POP
    }
    
    var operate:Operate?
    
    init(_ operate:Operate) {
        self.operate = operate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.8
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if operate == .PUSH {
            pushAnimation(transitionContext)
        } else {
            popAnimation(transitionContext)
        }
     
    }
    
    // push动画
    private func pushAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from) as! PhotosVC
        let toVC = transitionContext.viewController(forKey: .to) as! PhotoDetailVC
        let containerView = transitionContext.containerView
        let selectedCell = toVC.selectedCell!
        // 勾选照片的数量
        toVC.selectedCount = fromVC.selectedCount
        toVC.selectedCell!.selectBtn.isHidden = true
        
        let snapshotView = selectedCell.photoImageView.snapshotView(afterScreenUpdates: true)!
        snapshotView.frame = containerView.convert(selectedCell.photoImageView.frame, from: selectedCell)
        toVC.view.alpha = 0
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        containerView.addSubview(snapshotView)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        // 当前cell是否选中
        let isSelected = selectedCell.photoModel!.isSelected
        // 照片详情页 右上角选中标识
        toVC.rightSelectedButton.isSelected = isSelected
        
        // 目标cell的图片尺寸
        toVC.photosCollectionView.scrollToItem(at: toVC.indexPath!, at: .right, animated: true)
        
        UIView.animate(withDuration: 0.25, animations: {
            snapshotView.frame = containerView.convert( toVC.cellRect, from: toVC.detailCell)
        }) { (isFinished) in
            toVC.view.alpha = 1
            snapshotView.removeFromSuperview()
            toVC.selectedCell!.selectBtn.isHidden = false
            transitionContext.completeTransition(true)
        }
    }
    
    // pop动画
    private func popAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from) as! PhotoDetailVC
        let toVC = transitionContext.viewController(forKey: .to) as! PhotosVC
        let containerView = transitionContext.containerView
        
        let x = fromVC.photosCollectionView.contentOffset.x
        let indexPath = IndexPath.init(item: Int(x / SCREEN_W), section: 0)
        let currentCell = fromVC.photosCollectionView.cellForItem(at: IndexPath.init(item: Int(x / SCREEN_W), section: 0)) as! PhotoDetailCell
        let snapshotView = currentCell.largeImageView!.snapshotView(afterScreenUpdates: true)!
        snapshotView.frame = containerView.convert(currentCell.largeImageView.frame, from: currentCell.largeImageView)
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        containerView.addSubview(snapshotView)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        // 隐藏对应的列表中的cell
        let targetCell = toVC.photoCollection.cellForItem(at: indexPath) as! PhotoCell
        targetCell.isHidden = true
 
        print(targetCell.photoImageView.frame)
        
        UIView.animate(withDuration: 0.5, animations: {
            snapshotView.frame = containerView.convert(targetCell.photoImageView.frame, from: targetCell)
        }) { (isFinished) in
            targetCell.isHidden = false
            snapshotView.removeFromSuperview()
            toVC.photosArray = fromVC.photosArray!
            toVC.photoCollection.reloadData()
            transitionContext.completeTransition(true)
        }

    }
    
}
