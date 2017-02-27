//
//  SearchResultTV.swift
//  findtalents
//
//  Created by steven on 17/4/2016.
//  Copyright © 2016 steven. All rights reserved.
//

/**
 *HOW TO USE
 *
 *tvPredictCityResults.delegateForSearch = self
 *tvPredictCityResults.refreshWithResults(predicts)
 *and conform the SearchResultTVDelegate protocol to do work when select the predict cell
 */

import UIKit

protocol SearchResultTVDelegate: class {
    func didSelectResultCell(_ cell: UITableViewCell, selectedResult result:String, index:Int)
}

class SearchResultTV: UITableView, UITableViewDataSource, UITableViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var results: [String]
    weak var delegateForSearch: SearchResultTVDelegate!
    var maxHeight: CGFloat = 195.0;
    
    required init?(coder aDecoder: NSCoder) {
        results = []
        super.init(coder: aDecoder)
        
        dataSource = self
        delegate = self
        
    }
    
    init(frame: CGRect) {
        results = []
        super.init(frame: frame, style: UITableViewStyle.plain)
        
        dataSource = self
        delegate = self
    }
    
    func refreshWithResults(_ data: [String]) {
        results = data
        
        if data.count == 0 {
            self.isHidden = true
            return
        }
        reloadData()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
    }
    
    //MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        objc_sync_enter(results)
        if results.count == 0 {
            isHidden = true
        }
        else {
            isHidden = false
        }
        let count = results.count
        objc_sync_exit(results)
        
        return count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "resultCell")
        objc_sync_enter(results)
        cell.textLabel?.text = results[(indexPath as NSIndexPath).row]
        objc_sync_exit(results)
        return cell
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegateForSearch.didSelectResultCell(tableView.cellForRow(at: indexPath)!, selectedResult: results[(indexPath as NSIndexPath).row], index: (indexPath as NSIndexPath).row)
        
    }
}
