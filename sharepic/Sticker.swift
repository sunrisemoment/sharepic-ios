//
//  Sticker.swift
//  sharepic
//
//  Created by steven on 21/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit
//dictionary
//{
//    "sticker_id" => {
//        "title" => "I love you"
//    },
//    "sticker_id" => {
//        "title" => "I love you"
//    }
//}

open class Stickers: NSObject {
    
    open class var sharedInstance: Stickers {
        struct StickersSingleton {
            static let instance = Stickers()
        }
        return StickersSingleton.instance
    }
    
    var data: JSON!
    
    override init() {
        super.init()
        
        if let db = Stickers.createDB() {
            fmdb = db
        } else {
            // faild to create db
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(newStickersDownloadCompleted), name: NSNotification.Name(rawValue: kNOTIFICATION_NEW_STICKERS_DOWNLOAD_COMPLETED), object: nil)
    }
    
    func loadStickersToDB() -> Bool {
    
        if createTable() {
            if let path = Bundle.main.path(forResource: "stickers", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                    let jsonObj = JSON(data: data)
                    if jsonObj != JSON.null {
                        // store to db
                        if checkTableIsEmpty() {
                            self.fmdb.beginTransaction()
                            for (sticker_id, info) in jsonObj.dictionaryValue {
                                self.fmdb.executeUpdate("INSERT INTO stickers (sticker_id, title, filepath, timestamp) VALUES (?,?,?,?)", withArgumentsIn: [sticker_id , info["title"].stringValue, "", ""])
                            }
                            self.fmdb.commit()
                        }
                        let downloadedStickers = SharePicUtil.getDownloadedStickers()
                        for downloadedSticker in downloadedStickers {
                            if let _ = fetchStickersById(downloadedSticker.id) {
                            
                            } else {
                                _ = insertSticker(downloadedSticker.id, title: downloadedSticker.title, filePath: downloadedSticker.filepath!, timeStamp:"")
                            }
                        }
                        return true
                        
                    } else {
                        print("could not get json from file, make sure that file contains valid json.")
                        return false
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    return false
                }
            } else {
                print("Invalid filename/path.")
                return false
            }
        } else {
            return false
        }
        
    }
    
    func getTopViewController() -> UIViewController! {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    //MARK: - FMDB CRUD methods
    var fmdb : FMDatabase!
    
    static func createDB() -> FMDatabase! {
        
        var docsDir : String!
        var dirPaths : NSArray = NSArray()
        //get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        docsDir = dirPaths[0] as! String
        let db = FMDatabase(path: docsDir + "/sticker.db")
        return db
    }
    
    func createTable() -> Bool {
        if fmdb.open(){
            let sqlString = "CREATE TABLE IF NOT EXISTS stickers (sticker_id TEXT, title TEXT, filepath TEXT, timestamp TEXT)"
            fmdb.executeUpdate(sqlString, withArgumentsIn: [])
            return true
        } else {
            return false
        }
        
    }
    
    func insertSticker (_ sticker_id : String , title : String , filePath : String , timeStamp : String) -> Bool {
        let sqlString : String = "INSERT INTO stickers (sticker_id, title, filepath, timestamp) VALUES (?,?,?,?)"
        if self.fmdb.executeUpdate(sqlString, withArgumentsIn: [sticker_id , title, filePath, timeStamp]) {
            return true
        } else {
            return false
        }
    }
    
    func fetchStickers (_ title : String) -> [Sticker] {
        var sqlString : String
        if title == "" {
            sqlString = "SELECT * FROM stickers"
        } else {
            sqlString = "SELECT * FROM stickers WHERE title LIKE '%\(title)%'"
        }
        let result : FMResultSet = fmdb.executeQuery(sqlString,withArgumentsIn: [])
        var list: Array<Sticker> = Array<Sticker>()
        
        while result.next() {
            let stickerId = result.string(forColumn: "sticker_id")
            let title  = result.string(forColumn: "title")
            let filePath = result.string(forColumn: "filepath")
            let sticker : Sticker = Sticker(id: stickerId!, title: title!, filepath: filePath)
            list.append(sticker)
        }
        return list
    }
    
    func fetchStickersById (_ id : String) -> Sticker? {
//         let sqlString = "SELECT * FROM stickers WHERE sticker_id = \(id)"
        let sqlString : String = "SELECT * FROM stickers WHERE sticker_id = '\(id)'"
        if fmdb != nil {
             let result : FMResultSet = fmdb.executeQuery(sqlString, withArgumentsIn: [])
            if result.next() {
                let sticker : Sticker = Sticker(id: result.string(forColumn: "sticker_id"), title: result.string(forColumn: "title"), filepath: result.string(forColumn: "filepath"))
                return sticker
            }
        }
        return nil
    }

    func deleteAll() {
        let sqlString : String = "DELETE FROM stickers"
        fmdb.executeUpdate(sqlString, withArgumentsIn: [])
    }
    
    func checkTableIsEmpty() -> Bool {
        let sqlString = "SELECT * FROM stickers"
        let result : FMResultSet = fmdb.executeQuery(sqlString,withArgumentsIn: [])
        if result.next() {
            return false
        }else {
            return true
        }
    }

    
    var all: [Sticker] {
        get {
            var result = [Sticker]()
            for (sticker_id, info) in data.dictionaryValue {
                let sticker = Sticker(id: sticker_id, title: info["title"].stringValue, filepath: info["filepath"].string)
                result.append(sticker)
            }
            result.sort { (sticker1, sticker2) -> Bool in
                return sticker1.title < sticker2.title
            }
            return result;
        }
    }
    
    func newStickersDownloadCompleted() {
        _ = loadStickersToDB()
    }
    
    /**
    @param count if 0, then search in all recent stickers
    */
    func predictsInRecentStickers(_ key: String, count: Int) -> [Sticker] {
        let recentStickers = self.recentStickers(count)
        var predicts = [Sticker]()
        for sticker in recentStickers {
            if key.isEmpty {
                predicts.append(sticker)
            }
            else if sticker.title.lowercased().contains(key.lowercased()) {
                predicts.append(sticker)
            }
        }
        return predicts
    }
    
    //Recent stickers
//    [
//        {"sticker_id": "id", "timestamp": "123456"},
//        {"sticker_id": "id", "timestamp": "123456"}
//    ]
    func saveAsRecent(_ sticker_id: String) {
        
        var mutablearr: NSMutableArray?
        
        let ud = UserDefaults.standard
        var indexsToDelete = [Int]()
        if let arr = ud.object(forKey: "recent_stickers") as? NSArray {
            mutablearr = NSMutableArray(array: arr)
            for i in 0 ..< mutablearr!.count {
                let recent_sticker = mutablearr![i]
                let _sticker_id = (recent_sticker as! NSDictionary).object(forKey: "sticker_id") as! String
                if _sticker_id == sticker_id {
                    indexsToDelete.append(i)
                }
            }
        }
        for index in indexsToDelete {
            mutablearr?.removeObject(at: index)
        }
        
        let timeStamp: Double = Date().timeIntervalSince1970
        let dic = NSMutableDictionary()
        dic.setObject(timeStamp, forKey: "timestamp" as NSCopying)
        dic.setObject(sticker_id, forKey: "sticker_id" as NSCopying)
        
        if let _ = mutablearr {
            mutablearr!.insert(dic, at: 0)
        }
        else {
            mutablearr = NSMutableArray()
            mutablearr!.add(dic)
        }
        
        ud.set(mutablearr, forKey: "recent_stickers")
        ud.synchronize()
    }
    
    func isRecentSticker(_ sticker_id: String) -> Bool {
        let ud = UserDefaults.standard
        if let arr = ud.object(forKey: "recent_stickers") as? NSArray {
            for recent_sticker in arr {
                let _sticker_id = (recent_sticker as! NSDictionary).object(forKey: "sticker_id") as! String
                if _sticker_id == sticker_id {
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }
    
    /**
    @param count if 0, then return all rencet stickers
    */
    func recentStickers(_ count: Int) -> [Sticker] {
        var results = [Sticker]()
        
        let ud = UserDefaults.standard
        if let arr = ud.object(forKey: "recent_stickers") as? NSArray {
            if count == 0 {
                for recent_sticker in arr {
                    let _sticker_id = (recent_sticker as! NSDictionary).object(forKey: "sticker_id") as! String
                    let sticker = self.sticker(_sticker_id)!
                    results.append(sticker)
                }
            }
            else {
                var i = 0
                for recent_sticker in arr {
                    if (i == count) {
                        break
                    }
                    let _sticker_id = (recent_sticker as! NSDictionary).object(forKey: "sticker_id") as! String
                    let sticker = self.sticker(_sticker_id)!
                    results.append(sticker)
                    i += 1
                }
            }
        }
        
//        results.sortInPlace { (sticker1, sticker2) -> Bool in
//            return sticker1.title < sticker2.title
//        }
        return results;
    }
    
    func sticker(_ id: String) -> Sticker? {
        if let sticker : Sticker = fetchStickersById(id) {
            return sticker;
        }
        
        return nil
    }
    
    /**
    * group the stickers by its title, there may be several stickers that have same title, and these stickers are grouplized with its same title
    */
    func grouplizeByTitle(_ stickers: [Sticker]) -> [String: [Sticker]]? {
        var results = [String: [Sticker]]()
        for sticker in stickers {
            if let _ = results[sticker.title] {
                results[sticker.title]!.append(sticker)
            }
            else {
                results[sticker.title] = [Sticker]()
                results[sticker.title]!.append(sticker)
            }
        }
        return results;
    }
}

class Sticker: NSObject {
    
    init(id: String, title: String, filepath:String? = nil) {
        self.id = id;
        self.title = title
        self.filepath = filepath
        
        super.init()
    }
    
    fileprivate(set) var id: String
    
    fileprivate(set) var title: String
    
    var filename: String {
        get {
            return "\(id).png"
        }
    }
    
    var image: UIImage? {
        get {
            if let filepath = filepath {
                if !filepath.isEmpty {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: filepath)) {
                        return UIImage(data: data)
                    }
                    
                    return nil
                }
                
            }
            
            return UIImage(named: filename)
        }
    }
    
    //nil means it is default sticker embeded in the app
    var filepath: String?
    
    func saveAsRecent() {
        Stickers.sharedInstance.saveAsRecent(id)
    }
}
