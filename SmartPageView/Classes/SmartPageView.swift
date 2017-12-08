//
//  SmartPageView.swift
//  SmartPageViewController
//
//  Created by shock on 2017. 12. 7..
//  Copyright © 2017년 shock. All rights reserved.
//

import UIKit

open class SmartPageView: UIView {

    @IBOutlet var segmentHeader: SmartSegmentHeaderView?
    
    fileprivate var parentController: UIViewController?
    fileprivate var pageViewController: UIPageViewController?
    fileprivate var pageInfo:[(title:String, controller: UIViewController)] = []
    fileprivate var beforeIndex: Int = 0
    fileprivate var shouldScrollCurrentBar: Bool = true
    
    var currentIndex: Int? {
        guard let viewController = pageViewController?.viewControllers?.first else {
            return nil
        }
        return pageInfo.map({$0.controller}).index(of: viewController)
    }

    override open func awakeFromNib() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController!.delegate = self
        pageViewController!.dataSource = self
        let scrollView = pageViewController?.view.subviews.flatMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        segmentHeader?.delegate = self
    }
    
    public func setPageControllers(_ controller: UIViewController, pageInfo:[(title:String, controller: UIViewController)]) {
        self.parentController = controller
        self.pageInfo = pageInfo

        if let header = segmentHeader {
            header.titles = pageInfo.map{ $0.title }.joined(separator: ",")
        }
        
        pageViewController?.setViewControllers([pageInfo[0].controller], direction: .forward, animated: false, completion: {done in })
        parentController?.title = pageInfo[0].title
        parentController?.addChildViewController(pageViewController!)
        
        if let pageView = pageViewController?.view {
            self.addSubview(pageView)
        }
        
        pageViewController!.didMove(toParentViewController: parentController)
    }
}

extension SmartPageView: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        shouldScrollCurrentBar = true
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndex = currentIndex , currentIndex < pageInfo.count {
            beforeIndex = currentIndex
            parentController?.title = pageInfo[currentIndex].title
            segmentHeader?.setSelectedIndex(currentIndex)
        }
    }
}

extension SmartPageView: UIPageViewControllerDataSource {
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if (pageInfo.count == 0) || (index >= pageInfo.count) {
            return nil
        }
        
        return pageInfo[index].controller
    }
    
    func indexOfViewController(_ viewController: UIViewController) -> Int {
        return pageInfo.map({$0.controller}).index(of: viewController) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == pageInfo.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
}

extension SmartPageView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == self.bounds.width || !shouldScrollCurrentBar {
            return
        }
        
        if let index = currentIndex {
            segmentHeader?.setSelectedIndex(index)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}

extension SmartPageView: SmartSegmentHeaderDelegate {
    public func smartSegmentHeaderClicked(_ index: Int, title: String) {
        if let currentIndex = currentIndex {
            let header = segmentHeader
            segmentHeader = nil
            
            let direction = currentIndex < index ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse
            pageViewController?.setViewControllers([pageInfo[index].controller], direction: direction, animated: true, completion: { (_) in
                self.segmentHeader = header
            })
        }
    }
    
    public func smartSegmentHeaderDidChanged(_ index: Int, title: String) {}
}



