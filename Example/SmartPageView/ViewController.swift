//
//  ViewController.swift
//  SmartPageView
//
//  Created by ShockUtility on 12/08/2017.
//  Copyright (c) 2017 ShockUtility. All rights reserved.
//

import UIKit
import SmartPageView

class ViewController: UIViewController {

    @IBOutlet weak var smartPageView: SmartPageView!
    
    var currentPage = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var pageInfo: [(title: String, controller: UIViewController)] = []
        
        for (index, color) in [UIColor.red,UIColor.blue,UIColor.green,UIColor.yellow,UIColor.purple].enumerated() {
            let ctrl = UIViewController()
            ctrl.view.backgroundColor = color
            
            pageInfo.append((title:"Page \(index+1)", controller:ctrl))
        }
        
        self.smartPageView.setPageControllers(self, pageInfo: pageInfo, defaultPage: 1)
    }
    
    @IBAction func onClickAdd(_ sender: Any) {
        let ctrl = UIViewController()
        ctrl.view.backgroundColor = [UIColor.green,UIColor.red,UIColor.blue][currentPage % 3]
        
        self.smartPageView.insertPage(title: "New", controller: ctrl, index: currentPage+1)
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        self.smartPageView.deleteCurrentPage()
    }
    
    @IBAction func onClickPrev(_ sender: Any) {
        self.smartPageView.prevPage()
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        self.smartPageView.nextPage()
    }    
}

extension ViewController: SmartPageDelegate {
    func smartPageViewChanged(_ index: Int, title: String) {
        self.title = "\(title) (index = \(index))"
        currentPage = index
    }
}




