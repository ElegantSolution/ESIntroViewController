//
//  ESIntroScrollViewController.swift
//  Mymory
//
//  Created by Yue Zhao in April 2021.
//  Copyright © 2021 YueZhao@ElegantSolution. All rights reserved.
//

import UIKit


class ESIntroViewController: UIViewController {
    
    private class ESPageControl: UIPageControl{
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return false
        }
    }

    private let viewControllers: [UIViewController]
    
    private var idx = 0
    
    private let singlePageWidth: CGFloat = GLOBAL.windowRect.width
    
    private let singlePageHeight: CGFloat = GLOBAL.windowRect.height
    
    private let pageControlHeight: CGFloat = 50
    
    @objc
    private var scrollView: UIScrollView!
    
    private let offsetKeyPath = #keyPath(scrollView.contentOffset)
    
    private var pageControl: ESPageControl!
    
    init(viewControllers:[UIViewController]){
        
        self.viewControllers = viewControllers
        
        super.init(nibName: nil, bundle: nil)
        
        scrollView = addScrollView(viewControllers)
        
        observeScrollViewContentOffset()
        
        pageControl = addPageControl(viewControllers.count)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("ESIntroScrollViewController: should not use this method!")
    }
    
    
    deinit {
        
        removeObserver(self, forKeyPath: offsetKeyPath)
    }
}

extension ESIntroViewController{
    
    private func addScrollView(_ viewControllers: [UIViewController]) -> UIScrollView {
        
        let scrollView = initScrollViewHelper(viewControllers.count)
        
        return addViews(viewControllers, to: scrollView)
    }
    
    private func initScrollViewHelper(_ numOfViewController: Int) -> UIScrollView {
        
        let scrollView = UIScrollView(frame: GLOBAL.windowRect)
        
        let totalWidth = singlePageWidth * CGFloat(numOfViewController)
        
        scrollView.contentSize = CGSize(width: totalWidth, height: singlePageHeight)
        
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.isPagingEnabled = true
        
        scrollView.bounces = false
        
        return scrollView
    }
    
    
    private func addViews(_ viewControllers: [UIViewController], to scrollView: UIScrollView) -> UIScrollView {
        
        view.addSubview(scrollView)
        
        for i in 0 ..< viewControllers.count {
            
            self.addChild(viewControllers[i])
            
            let view = viewControllers[i].view as UIView
            
            view.frame = CGRect(x: CGFloat(i) * singlePageWidth, y: 0, width: singlePageWidth, height: singlePageHeight)
            
            scrollView.addSubview(view)
            
            viewControllers[i].didMove(toParent: self)
        }
        
        return scrollView
    }
    
    
    private func addPageControl(_ numOfPages: Int) -> ESPageControl {

        let frame = CGRect(x: 0, y: singlePageHeight - pageControlHeight, width: singlePageWidth, height: pageControlHeight)
        
        let pageControl = ESPageControl(frame: frame)
        
        pageControl.numberOfPages = numOfPages
        
        pageControl.currentPage = 0
        
        view.addSubview(pageControl)
        
        view.bringSubviewToFront(pageControl)
        
        return pageControl
    }
}


extension ESIntroViewController {
    
    private func observeScrollViewContentOffset() {
        
        addObserver(self, forKeyPath: offsetKeyPath, options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard keyPath == offsetKeyPath, let newValue = change?[NSKeyValueChangeKey.newKey] as? CGPoint else {
            return
        }
        
        let offsetX = Int(newValue.x)
    
        let width = Int(singlePageWidth)
        
        guard offsetX % width == 0 else {
            return
        }
        
        let i = offsetX / width
        
        if i != idx {
            
            idx = i
            pageControl.currentPage = i
            
        }
    }
}
