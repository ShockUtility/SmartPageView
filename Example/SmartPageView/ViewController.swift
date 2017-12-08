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

    @IBOutlet weak var smartSegmentHeaderView: SmartSegmentHeaderView!
    @IBOutlet weak var smartPageView: SmartPageView!
    
    var pageInfo: [(title: String, controller: UIViewController)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for (index, color) in [UIColor.red,UIColor.blue,UIColor.green,UIColor.yellow,UIColor.purple].enumerated() {
            let ctrl = UIViewController()
            ctrl.view.backgroundColor = color
            pageInfo.append((title:"PageX \(index+1)", controller:ctrl))
        }
        
        self.smartPageView.setPageControllers(self, pageInfo: pageInfo)
    }
}




