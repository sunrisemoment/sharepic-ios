//
//  StevenPullRefreshAndInfiniteSV.swift
//  FindTalents
//
//  Created by steven on 18/5/2016.
//  Copyright © 2016 steven. All rights reserved.
//

import Foundation

protocol StevenPullRefreshAndInfiniteSVDelegate: class {
    func insertNewFetchedResultToDataSource(serverData data: Data)
    func reloadDataWithServerData(_ data: Data)
    
    func refreshTableSuccess()
    func refreshTableFailed(_ error: NSError?)
    
    func insertNewFetchedRowsSuccess()
    func insertNewFetchedRowsFailed(_ error: NSError?)
}

extension StevenPullRefreshAndInfiniteSVDelegate {
    func refreshTableSuccess() {
        
    }
    func refreshTableFailed(_ error: NSError?) {
        
    }
    
    func insertNewFetchedRowsSuccess() {
        
    }
    func insertNewFetchedRowsFailed(_ error: NSError?) {
        
    }
}

protocol StevenPullRefreshAndInfiniteSVDataSource: class {
    func tableForPullRefreshAndInfiniteSV() -> UITableView
    func datasourceForTableView()   -> Array<AnyObject>
    func cellLimitOnceShown() -> Int
}

class StevenPullRefreshAndInfiniteSV {
    weak var delegate: StevenPullRefreshAndInfiniteSVDelegate!
    weak var dataSource: StevenPullRefreshAndInfiniteSVDataSource!
    
//    func set(_delegate: StevenPullRefreshAndInfiniteSVDelegate, _dataSource: StevenPullRefreshAndInfiniteSVDataSource) {
//        self.delegate = _delegate
//        self.dataSource = _dataSource
//        
//        let tableView = dataSource.tableForPullRefreshAndInfiniteSV()
//        var data = dataSource.tableForPullRefreshAndInfiniteSV()
//        var cellLimit = dataSource.cellLimitOnceShown()
//        
//        tableView.addPullToRefreshWithActionHandler {
//            self.refreshJobTable(success: {
//                tableView.pullToRefreshView.stopAnimating()
//                self.delegate.refreshTableSuccess()
//                }, fail: { (error) in
//                    tableView.pullToRefreshView.stopAnimating()
//                    self.delegate.refreshTableFailed(nil)
//            })
//            
//        }
//        //setup infinitescrollview
//        tableView.addInfiniteScrollingWithActionHandler {
//            self.insertFetchedJobs(success: {
//                tableView.infiniteScrollingView.stopAnimating()
//                self.delegate.insertNewFetchedRowsSuccess()
//                }, fail: { (error) in
//                    tableView.infiniteScrollingView.stopAnimating()
//                    self.delegate.insertNewFetchedRowsFailed(nil)
//            })
//        }
//        //reload data for the initial data
//        refreshJobTable(success: nil, fail: { (error) in
//            self.delegate.refreshTableFailed(nil)
//        })
//    }
//    
//    func refreshJobTable(success success:(()->Void)?, fail:(()->Void)? ) {
//        self.thisJob.reloadAppliedTalents(offset: -1, limit: CELL_LIMIT, success: { (data) in
//            
//            let response = JSON(data: data)
//            self.proposalTalents = [User]()
//            for(_, talent_jsonData) in response {
//                var talent_data = talent_jsonData
//                talent_data["Type"] = "Talent"
//                self.proposalTalents.append(User(swiftJson: talent_data))
//            }
//            self.tableProposals.reloadData()
//            success?();
//            }, fail: { (error) in
//                fail?()
//        })
//    }
//    
//    func insertFetchedJobs(success success:(()->Void)?, fail:(()->Void)?) {
//        let count = proposalTalents.count
//        var offset = -1
//        if count > 0 {
//            let lastobj_id = proposalTalents[count - 1].id
//            offset = Int.init(lastobj_id)!
//        }
//        self.thisJob.reloadAppliedTalents(offset: offset, limit: CELL_LIMIT, success: { (data) in
//            let newData = JSON(data:data)
//            if newData.count == 0 {
//                success?()
//            }
//            else {
//                self.tableProposals.beginUpdates()
//                var count = self.proposalTalents.count
//                var updateIndexPaths = [NSIndexPath]()
//                for (_, item) in newData {
//                    var talent_data = item
//                    talent_data["Type"] = "Talent"
//                    self.proposalTalents.append(User(swiftJson: talent_data))
//                    
//                    updateIndexPaths.append(NSIndexPath(forRow: count, inSection: 0))
//                    count += 1
//                }
//                self.tableProposals.insertRowsAtIndexPaths(updateIndexPaths, withRowAnimation: UITableViewRowAnimation.Top)
//                self.tableProposals.endUpdates()
//                success?();
//            }
//            }, fail: { (error) in
//                fail?()
//        })
//    }
}
