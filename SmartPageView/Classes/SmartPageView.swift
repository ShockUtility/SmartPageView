//
//  SmartPageView.swift
//  SmartPageViewController
//
//  Created by shock on 2017. 12. 7..
//  Copyright © 2017년 shock. All rights reserved.
//

import UIKit

@objc public protocol SmartPageDelegate: NSObjectProtocol {
    func smartPageViewChanged(_ index: Int, title: String)
}

open class SmartPageView: UIView {

    @IBOutlet open weak var delegate: SmartPageDelegate?
    @IBOutlet open var segmentHeader: SmartSegmentView?
    
    fileprivate var parentController: UIViewController?
    fileprivate var pageViewController: UIPageViewController?
    fileprivate var pageInfo = [(title:String, controller: UIViewController)]()
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
    
    public func setPageControllers(_ controller: UIViewController, pageInfo:[(title:String, controller: UIViewController)], defaultPage: Int = 0) {
        let firstPage = min(defaultPage, pageInfo.count-1)
        
        self.parentController = controller
        self.pageInfo = pageInfo

        if let header = segmentHeader {
            header.titles = pageInfo.map{ $0.title }.joined(separator: ",")
            header.setSelectedIndex(firstPage, animated: false)
        }
        
        delegate?.smartPageViewChanged(firstPage, title: pageInfo[firstPage].title)
        pageViewController?.setViewControllers([pageInfo[firstPage].controller], direction: .forward, animated: false, completion: {done in })
        parentController?.addChildViewController(pageViewController!)
        
        if let pageView = pageViewController?.view {
            self.addSubview(pageView)
            
            let views = ["pageView": pageView]
            pageView.translatesAutoresizingMaskIntoConstraints = false            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageView]|", options: .alignAllCenterY, metrics: nil, views: views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pageView]|", options: .alignAllCenterX, metrics: nil, views: views))
        }
        
        pageViewController!.didMove(toParentViewController: parentController)
    }
    
    public func setPage(index: Int, direction: UIPageViewControllerNavigationDirection, isChangeHeader: Bool = true) {
        let saveHeader = segmentHeader
        
        if !isChangeHeader {
            segmentHeader = nil
            saveHeader?.setSelectedIndex(index, animated: false)
        }
        
        pageViewController?.setViewControllers([pageInfo[index].controller], direction: direction, animated: true, completion: { (_) in
            if saveHeader != nil {
                self.segmentHeader = saveHeader
            }
            self.delegate?.smartPageViewChanged(index, title: self.pageInfo[index].title)
        })
    }
    
    public func prevPage() {
        if let idx = currentIndex, idx > 0 {
            setPage(index: idx-1, direction: .reverse)
        }
    }
    
    public func nextPage() {
        if let idx = currentIndex, idx < pageInfo.count-1 {
            setPage(index: idx+1, direction: .forward)
        }
    }
    
    public func deleteCurrentPage() {
        if pageInfo.count > 1, let idx = currentIndex {
            if let saveHeader = segmentHeader {
                segmentHeader = nil
                var arrTitle =  saveHeader.titles.components(separatedBy: ",")
                arrTitle.remove(at: idx)
                saveHeader.titles = arrTitle.joined(separator: ",")
                segmentHeader = saveHeader
            }
            pageInfo.remove(at: idx)
            
            let newPage = min(idx, pageInfo.count-1)
            setPage(index: newPage, direction: (newPage == idx) ? .forward : .reverse, isChangeHeader: false)
        }
    }
    
    public func insertPage(title: String, controller: UIViewController, index: Int) {
        if let header = segmentHeader {
            var arrTitle =  header.titles.components(separatedBy: ",")
            arrTitle.insert(title, at: index)
            header.titles = arrTitle.joined(separator: ",")
        }
        pageInfo.insert((title: title, controller: controller), at: index)
        
        setPage(index: index, direction: .forward, isChangeHeader: false)
    }
}

extension SmartPageView: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        shouldScrollCurrentBar = true
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndex = currentIndex , currentIndex != NSNotFound {
            beforeIndex = currentIndex
            segmentHeader?.setSelectedIndex(currentIndex)
            delegate?.smartPageViewChanged(currentIndex, title: pageInfo[currentIndex].title)
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

extension SmartPageView: SmartSegmentViewDelegate {
    public func smartSegmentViewClicked(_ index: Int, title: String) {
        if let currentIndex = currentIndex {
            let direction:UIPageViewControllerNavigationDirection = currentIndex < index ? .forward : .reverse
            setPage(index: index, direction: direction, isChangeHeader: false)
        }
    }
    
    public func smartSegmentViewChanged(_ index: Int, title: String) {}
}




