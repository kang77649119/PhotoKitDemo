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
        
        let snapshotView = selectedCell.photoImageView.snapshotView(afterScreenUpdates: true)!
        snapshotView.frame = containerView.convert(selectedCell.photoImageView.frame, from: selectedCell)
        toVC.view.alpha = 0
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        containerView.addSubview(snapshotView)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        UIView.animate(withDuration: 0.1, animations: {
            snapshotView.frame = containerView.convert(toVC.cellRect, from: toVC.detailCell)
            toVC.photosCollectionView.scrollToItem(at: toVC.indexPath!, at: .right, animated: false)
        }) { (isFinished) in
            print(Thread.current)
            toVC.view.alpha = 1
            snapshotView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
    // pop动画
    private func popAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from) as! PhotoDetailVC
        let toVC = transitionContext.viewController(forKey: .to) as! PhotosVC
        let containerView = transitionContext.containerView
        
        let x = fromVC.photosCollectionView.contentOffset.x
        let currentCell = fromVC.photosCollectionView.cellForItem(at: IndexPath.init(item: Int(x / SCREEN_W), section: 0)) as! PhotoDetailCell
        let snapshotView = currentCell.largeImageView!.snapshotView(afterScreenUpdates: true)!
        snapshotView.frame = containerView.convert(currentCell.largeImageView.frame, from: currentCell)
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        containerView.addSubview(snapshotView)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        let sourceCell = toVC.photoCollection.cellForItem(at: IndexPath.init(item: Int(x / SCREEN_W), section: 0)) as! PhotoCell
        sourceCell.photoImageView.isHidden = true
        print(sourceCell.photoImageView.frame)
        
        UIView.animate(withDuration: 0.5, animations: {
            snapshotView.frame = containerView.convert(sourceCell.photoImageView.frame, from: sourceCell)
        }) { (isFinished) in
            sourceCell.photoImageView.isHidden = false
            snapshotView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
}
