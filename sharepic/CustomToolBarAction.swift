//
//  CutomToolBarAction.swift
//  sharepic
//
//  Created by steven on 14/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit

protocol CustomToolBarActionDelegate: class {
    func didSelectedToolBarItem(_ item: UIButton)
    func didDeselectToolBarItem(_ item: UIButton)
}

class CustomToolBarAction: NSObject {
    fileprivate(set) var currentSelectedItem: UIButton!
    
    weak var delegate: CustomToolBarActionDelegate?
    
    init(toolBarItems: [UIButton], delegate: CustomToolBarActionDelegate) {
        super.init()
        
        self.toolBarItems = toolBarItems
        self.delegate = delegate
        
        for item in self.toolBarItems {
            item.addTarget(self, action: #selector(CustomToolBarAction.onClick(_:)), for: .touchUpInside)
        }
    }
    
    var toolBarItems = [UIButton]() {
        didSet {
            for item in toolBarItems {
                item.addTarget(self, action: #selector(CustomToolBarAction.onClick(_:)), for: .touchUpInside)
            }
        }
    }
    
    func onClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if (sender != currentSelectedItem) && (currentSelectedItem != nil) {
            onClick(currentSelectedItem)
        }
        
        for item in toolBarItems {
            if item == sender {
                if item.isSelected {
                    delegate?.didSelectedToolBarItem(item)
                    currentSelectedItem = item
                }
                else {
                    delegate?.didDeselectToolBarItem(item)
                    currentSelectedItem = nil
                }
            }
        }
    }
    
    func deSelectItem(_ item: UIButton) {
        item.isSelected = false
        delegate?.didDeselectToolBarItem(item)
        currentSelectedItem = nil
    }
    
    func deSelectItemWithoutDelegateCall(_ item: UIButton) {
        item.isSelected = false
        currentSelectedItem = nil
    }
    
    func selectItem(_ item: UIButton) {
        item.isSelected = true
        
        if (item != currentSelectedItem) && (currentSelectedItem != nil) {
            onClick(currentSelectedItem)
        }
        
        delegate?.didSelectedToolBarItem(item)
        currentSelectedItem = item
    }
}
