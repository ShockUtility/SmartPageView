//
//  SmartSegmentHeader.swift
//  SmartHeader
//
//  Created by shock on 2017. 12. 8..
//  Copyright © 2017년 shock. All rights reserved.
//

import UIKit

@objc public protocol SmartSegmentViewDelegate: NSObjectProtocol {
    func smartSegmentViewClicked(_ index: Int, title: String)
    func smartSegmentViewChanged(_ index: Int, title: String)
}

@IBDesignable
open class SmartSegmentView: UIView {

    @IBOutlet open weak var delegate: SmartSegmentViewDelegate?
    
    @IBInspectable var titles: String = "Page 1,Page 2,Page 3,Page 4,Page 5" {
        didSet {
            for button in self.stackView.arrangedSubviews {
                button.removeFromSuperview()
            }
            updateButtons()
        }
    }
    @IBInspectable open var indicatorHeight   : CGFloat = 2.0 { didSet { updateConstraintIndicatorPosition() } }
    @IBInspectable open var isIndicatorFixed  : Bool = false  { didSet { updateConstraintIndicatorPosition() } }
    @IBInspectable open var isIndicatorTop    : Bool = false  { didSet { updateConstraintIndicatorDirection() } }
    @IBInspectable open var indicatorColor    : UIColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)  { didSet { self.indicatorView.backgroundColor = indicatorColor } }
    @IBInspectable open var titleFontSize     : CGFloat = 15  { didSet { updateTitleAttributes() } }
    @IBInspectable open var titleNormalColor  : UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)  { didSet { updateTitleAttributes() } }
    @IBInspectable open var titleSelectedColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)  { didSet { updateTitleAttributes() } }

    fileprivate var indicatorConstraints : (
        position: NSLayoutConstraint?,
        leading: NSLayoutConstraint?,
        width: NSLayoutConstraint?,
        height: NSLayoutConstraint?)

    fileprivate var titleArray: [String] {
        return titles.components(separatedBy: ",")
    }
    fileprivate(set) var selectedIndex: Int = 0 {
        didSet {
            for case let button as UIButton in stackView.arrangedSubviews {
                button.isSelected = false
            }
            
            let selectedButton = stackView.arrangedSubviews[selectedIndex] as! UIButton
            selectedButton.isSelected = true
        }
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.indicatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override open func updateConstraints() {
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)])
        
        updateConstraintIndicatorDirection()
        updateConstraintIndicatorPosition();
        
        super.updateConstraints()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        addSubview(stackView)
        addSubview(indicatorView)
        bringSubviewToFront(indicatorView)
        
        updateButtons()
    }
}

// Constraint

extension SmartSegmentView {
    
    func updateConstraintIndicatorDirection() {
        if let constraint = indicatorConstraints.position {
            removeConstraint(constraint)
        }
        
        indicatorConstraints.position = isIndicatorTop
            ? indicatorView.topAnchor.constraint(equalTo: stackView.topAnchor)
            : indicatorView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        
        NSLayoutConstraint.activate([indicatorConstraints.position!])
    }
    
    func updateConstraintIndicatorPosition() {
        for constraint in [indicatorConstraints.leading, indicatorConstraints.width] {
            if let constraint = constraint {
                removeConstraint(constraint)
            }
        }
        if let constraint = indicatorConstraints.height {
            indicatorView.removeConstraint(constraint)
        }
        
        if isIndicatorFixed {
            indicatorConstraints.leading = indicatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
            indicatorConstraints.width   = indicatorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / CGFloat(titleArray.count))
        } else {
            let button = stackView.arrangedSubviews[selectedIndex] as? UIButton
            if let titleLabel = button?.titleLabel {
                indicatorConstraints.leading = indicatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
                indicatorConstraints.width   = indicatorView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor)
            }
        }
        indicatorConstraints.height = indicatorView.heightAnchor.constraint(equalToConstant: indicatorHeight)
        
        NSLayoutConstraint.activate([
            indicatorConstraints.leading!,
            indicatorConstraints.width!,
            indicatorConstraints.height!])
    }
}

// Custom

extension SmartSegmentView {
    
    func updateTitleAttributes() {
        let normalAttr: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.foregroundColor : titleNormalColor,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: titleFontSize)]
        let selectedAttr: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.foregroundColor : titleSelectedColor,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: titleFontSize)]
        
        for case let button as UIButton in stackView.arrangedSubviews {
            if let title = button.title(for: .normal) {
                button.setAttributedTitle(NSAttributedString(string: title, attributes: normalAttr), for: .normal)
                button.setAttributedTitle(NSAttributedString(string: title, attributes: selectedAttr), for: .selected)
            }
        }
    }
    
    func updateButtons() {
        for (index, item) in titleArray.enumerated() {
            let button = UIButton()
            button.setTitle(item, for: .normal)
            button.addTarget(self, action: #selector(SmartSegmentView.onClickTap(segmentButton:)), for: .touchUpInside)
            button.tag = index
            stackView.addArrangedSubview(button)
        }
        
        updateTitleAttributes()
        setSelectedIndex(0, animated: false)
    }
    
    @objc func onClickTap(segmentButton sender: UIButton) {
        let newIndex = sender.tag
        let indexChanged: Bool = newIndex != selectedIndex
        selectedIndex = newIndex
        
        if indexChanged {
            delegate?.smartSegmentViewClicked(newIndex, title: titleArray[newIndex])
        }
        
        setSelectedIndex(newIndex)
    }
    
    open func setSelectedIndex(_ index: Int, animated: Bool = true) {
        if (index >= titleArray.count) {
            return
        }
        
        selectedIndex = index
        
        if isIndicatorFixed {
            let segmentWidth = stackView.frame.size.width / CGFloat(titleArray.count)
            indicatorConstraints.leading?.constant = segmentWidth * CGFloat(index)
        } else {
            let button = stackView.arrangedSubviews[selectedIndex] as? UIButton
            
            if let titleLabel = button?.titleLabel {
                if let constraint = indicatorConstraints.width {
                    removeConstraint(constraint)
                }
                if let constraint = indicatorConstraints.leading {
                    removeConstraint(constraint)
                }
                
                indicatorConstraints.leading = indicatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
                indicatorConstraints.width = indicatorView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor)
                
                NSLayoutConstraint.activate([indicatorConstraints.width!, indicatorConstraints.leading!])
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
                self.delegate?.smartSegmentViewChanged(index, title: self.titleArray[index])
            })
        } else {
            self.layoutIfNeeded()
            self.delegate?.smartSegmentViewChanged(index, title: titleArray[index])
        }
    }
}






