//
//  SharePicUtil.swift
//  sharepic
//
//  Created by steven on 15/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit
import Firebase

class ToolBarMenuItem: UIView {
    
    var identity: String!
    var iconView: UIImageView!
    var titleLabel: UILabel!
    var isTitleSupport: Bool = true
    
    var selected: Bool = false {
        didSet {
            if selected {
                self.iconView.layer.borderColor = UIColor.white.cgColor
                self.iconView.layer.borderWidth = 2
            }
            else {
                self.iconView.layer.borderWidth = 0
            }
        }
    }
    
    init(frame: CGRect, isGapSupport: Bool = true, isTitleSupport: Bool = true) {
        super.init(frame: frame)
        
        let W: CGFloat = frame.size.width
        self.isTitleSupport = isTitleSupport;

        if isTitleSupport {
            if isGapSupport {
                iconView = UIImageView(frame: CGRect(x: 7.5, y: 5, width: W-15, height: W-15))
                titleLabel = UILabel(frame: CGRect(x: 0, y: iconView.bottom + 2, width: W, height: 10))
            }
            else {
                iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: W, height: W-10))
                titleLabel = UILabel(frame: CGRect(x: 0, y: iconView.bottom, width: W, height: 10))
            }
            
            iconView.clipsToBounds = true
            iconView.contentMode = .scaleAspectFill
            addSubview(iconView)
            
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont(name: "Helvetica-Bold", size: 10)
                
            addSubview(titleLabel)
        }
        else {
            if isGapSupport {
                iconView = UIImageView(frame: CGRect(x: 2.5, y: 2.5, width: W-5, height: W-5))
            }
            else {
                iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: W, height: W))
            }
            iconView.clipsToBounds = true
            iconView.contentMode = .scaleAspectFill
            addSubview(iconView)
        }
        
    }
    
    convenience init(frame: CGRect, target: AnyObject?, action: Selector?, isGapSupport: Bool = true, isTitleSupport: Bool = true) {
        self.init(frame: frame, isGapSupport: isGapSupport, isTitleSupport: isTitleSupport)
        
        if let target = target {
            let gesture = UITapGestureRecognizer(target: target, action: action)
            self.addGestureRecognizer(gesture)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class SharePicUtil: NSObject {
    
    static let sharedInstance = SharePicUtil()
    
    static func showSystemAlert(title: String?, message: String?, dismissButtonTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let dismissTitle = dismissButtonTitle {
            let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
            alert.addAction(dismissAction)
        }
        else {
            let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    var screenWidth: CGFloat {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
    
    var screenHeight: CGFloat {
        get {
            return UIScreen.main.bounds.size.height
        }
    }
    
    //FONT UTILITY

//Recent font storage
//    [
//        {"fontname": "fontname", "size": 15.0 CGFloat},
//        {"fontname": "fontname", "size": 16.0 CGFloat}
//    ]
    static func saveAsRecentFont(_ font: UIFont) {
        var mutablearr: NSMutableArray?
        
        let ud = UserDefaults.standard
        if let arr = ud.object(forKey: "recent_fonts") as? NSArray {
            mutablearr = NSMutableArray(array: arr)
            for recent_font in mutablearr! {
                let _fontname = (recent_font as! NSDictionary).object(forKey: "fontname") as! String
                let _size = (recent_font as! NSDictionary).object(forKey: "size") as! CGFloat
                if (_fontname == font.fontName) && (_size == font.pointSize){
                    mutablearr!.remove(recent_font)
                }
            }
        }
        
        let dic = NSMutableDictionary()
        dic.setObject(font.fontName, forKey: "fontname" as NSCopying)
        dic.setObject(font.pointSize, forKey: "size" as NSCopying)
        
        if let _ = mutablearr {
            mutablearr!.insert(dic, at: 0)
        }
        else {
            mutablearr = NSMutableArray()
            mutablearr!.add(dic)
        }
        
        ud.set(mutablearr, forKey: "recent_fonts")
        ud.synchronize()
    }
    
    static func recentFonts(_ count: Int) -> [UIFont] {
        var results = [UIFont]()
        
        let ud = UserDefaults.standard
        if let arr = ud.object(forKey: "recent_fonts") as? NSArray {
            var i = 0
            for recent_font in arr {
                if (i == count) {
                    break
                }
                let _fontname = (recent_font as! NSDictionary).object(forKey: "fontname") as! String
                let _fontsize = (recent_font as! NSDictionary).object(forKey: "size") as! CGFloat
                results.append(UIFont(name: _fontname, size: _fontsize)!)
                i += 1
            }
        }
        return results;
    }
    
    static func fitImageToImageCropContainerSize(_ image: UIImage) -> UIImage {
        let container_width = UIScreen.main.bounds.size.width
        let container_height = UIScreen.main.bounds.size.height - TOOLBAR_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT
        
        let ratio: CGFloat = container_width / container_height
        var toSize: CGSize = CGSize(width: 0, height: 0)
        
        if image.size.height > 4000 {
            toSize.height = 4000
        }
        else {
            toSize.height = image.size.height
        }
        
        toSize.width = toSize.height * ratio
        
        return image.aspectFit(toSize)
    }
    
    static func setShadow(_ view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        view.layer.shadowOpacity = 0.5
    }
    
    //FireBase
    fileprivate static var _currentUser: FIRUser!
    static var currentUser: FIRUser! {
        get {
            if let _ = _currentUser {
                return _currentUser
            }
            else {
                return FIRAuth.auth()?.currentUser
            }
        }
        set {
            _currentUser = newValue
        }
    }
    
    //MARK: - Users Table Handling
    
    
    static func SharepicDataBase() -> FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    //tables and storage
    static let UserTable = "users"
    static let SuggestedWordsTable = "stickers"
    static let UseStickerTable = "useStickers"
    static let StorageUrl = "gs://palpic-6af26.appspot.com"
    static let StickerPath = "stickers/"
    static let JsonInfoPath = "jsons/"
    static let ShaprepicStorage = FIRStorage.storage().reference(forURL: StorageUrl)
    
    static let SuggestedWordCompletedState = "Completed"


    static func setUserData(_ userID: String, email: String, FBName: String, completion: ((_ error: NSError?, _ ref: FIRDatabaseReference)->Void)?) { //UPDATE00001
        let userTable = SharePicUtil.SharepicDataBase().child(UserTable)
        
        var lang: [String?] = []
        let activeLang = Locale.preferredLanguages.count
        
        for i in 0...2{
            if i < activeLang{
                let langID = Locale.preferredLanguages[i]
                lang.append((Locale.current as NSLocale).displayName(forKey: NSLocale.Key.languageCode, value: langID))
            } else {
                lang.append("Nil")
            }
        }
    
        let countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let country = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
        
        userTable.child(userID).observeSingleEvent(of: .value, with: {(dataSnap) in
            let data: [String: String] = ["email": email, "FBName": FBName, "preferred_lang0": lang[0]!, "preferred_lang1": lang[1]!, "preferred_lang2": lang[2]!, "region": country!, "FCMToken": FCMToken]  //UPDATE00001 UPDATE00002
            userTable.child(userID).updateChildValues(data, withCompletionBlock: { (error, ref) in
                completion?(error as NSError?, ref)
            })
        })
    }
    
    static func getUserInfo(_ userID: String, completion: @escaping ((_ userInfo: NSDictionary?)->Void)) {
        let userTable = SharePicUtil.SharepicDataBase().child(UserTable)
        
        userTable.child(userID).observeSingleEvent(of: .value, with: {(dataSnap) in
            if dataSnap.exists() {
                completion(dataSnap.value as? NSDictionary)
            }
            else {
                completion(nil)
            }
        })
    }
    
    //MARK: - SuggestWord Table Handling
    
    static func setSuggestedWord(_ userID: String, suggestedWord: String, completion: ((_ error: NSError?, _ ref: FIRDatabaseReference)->Void)?) {
        
        let table = SharePicUtil.SharepicDataBase().child(SuggestedWordsTable)
        
        let timestamp = FIRServerValue.timestamp()
        let data: [AnyHashable: Any] = ["suggestedWord": suggestedWord, "timestamp": timestamp, "status": "Suggested"] 
        table.child(userID + "/" + table.childByAutoId().key).updateChildValues(data) { (error, ref) in
            completion?(error as NSError?, ref)
        }
    }
    
    static func setSuggestedWords(_ userID: String, suggestedWords: [String], completion: ((_ error: NSError?, _ ref: FIRDatabaseReference)->Void)?) {
        
        let table = SharePicUtil.SharepicDataBase().child(SuggestedWordsTable)
        
        let timestamp = FIRServerValue.timestamp()
        
        var data = [AnyHashable: Any]()
        for suggestedWord in suggestedWords {
            data[table.childByAutoId().key] = ["suggestedWord": suggestedWord, "timestamp": timestamp, "status": "Suggested"]
        }
        
        table.child(userID).updateChildValues(data) { (error, ref) in
            completion?(error as NSError?, ref)
        }
    }
    

    static func setStickerUse(_ userID: String, stickersId: [String], completion: ((_ error: NSError?, _ ref: FIRDatabaseReference)->Void)?) {
        let table = SharePicUtil.SharepicDataBase().child(UseStickerTable)
        let timestamp = FIRServerValue.timestamp()
        let data: [AnyHashable: Any] = ["userID": userID, "timestamp": timestamp]
        for stickerId in stickersId{
            table.child(stickerId + "/" + table.childByAutoId().key).updateChildValues(data) { (error, ref) in completion?(error as NSError?, ref)
            }
        }
    }
    
    static func fetchSuggestedWordInfo(_ userId: String, suggestedWord_id: String, completion:@escaping ((_ suggestedWord_info: NSDictionary?)->Void)) {
        
        let table = SharePicUtil.SharepicDataBase().child(SuggestedWordsTable + "/" + userId + "/" + suggestedWord_id)
        
        table.observeSingleEvent(of: .value, with: { (dataSnap) in
            if dataSnap.exists() {
                completion(dataSnap.value as? NSDictionary)
            }
            else {
                completion(nil)
            }
        })
    }
    
    //MARK: - Sticker Storage Handling
    /**
     sticker_id is the id in the json file for the suggestedWord_id
    */
    static let downloadStickerSerialQueue = DispatchQueue(label: "downloadStickerSerialQueue", attributes: [])
    static func downloadSticker(_ sticker_id: String, suggestWord_id: String, completion: @escaping ((NSError?, Sticker?)->Void)) {
        fetchSuggestedWordInfo(currentUser.uid, suggestedWord_id: suggestWord_id) { (suggestedWord_info) in
            if let word_info = suggestedWord_info {
                
                let storage = FIRStorage.storage()
                let storageRef = storage.reference(forURL: StorageUrl)
                let pathRef = storageRef.child(StickerPath + sticker_id + ".png")
                pathRef.downloadURL { (url, error) in
                    if let url = url {
                        downloadStickerSerialQueue.async(execute: {
                            if let data = try? Data(contentsOf: url) {
                                let filename = sticker_id + ".png"
                                let filepath = CommonFunc.documentsPath(forFileName: filename)
                                if (try? data.write(to: URL(fileURLWithPath: filepath!), options: [.atomic])) != nil {
                                    
                                    let sticker = Sticker(id: sticker_id, title: word_info["suggestedWord"] as! String, filepath: filepath)
                                    registerStickerAsDownloaded(sticker, word_id: suggestWord_id)
                                    DispatchQueue.main.async(execute: { 
                                        completion(nil, sticker)
                                    })
                                }
                                else {
                                    
                                }
                            }
                            else {
                                
                            }
                        })
                    }
                    else {
                        completion(error as NSError?, nil)
                    }
                }
            }
            else {
                
            }
        }
    }
    
    
    //MARK: - Register/Retrieve Suggested Words
    static func registerSuggestedWordAsDownloaded(_ suggested_id: String) {
        
        var sugWords = getDownloadedSuggestedWords()
        
        if sugWords.contains(suggested_id) {
            return
        }
        
        sugWords.append(suggested_id)
        
        let userDefault = UserDefaults.standard
        userDefault.set(sugWords, forKey: "downloadedWords")
        userDefault.synchronize()
    }
    
    static func getDownloadedSuggestedWords() -> [String] {
        let userDefault = UserDefaults.standard
        if let words = userDefault.object(forKey: "downloadedWords") as? [String] {
            return words
        }
        else {
            return [String]()
        }
    }
    
    //MARK: - Register/Retrieve StickerInfo for suggested word which is downloaded
    //userDefaults -> {"downloadedStickers" : {"word_id": [{sticker_info}, {sticker_info}], "word_id": [{sticker_info}, {sticker_info}, {sticker_info}]}}
    fileprivate static let serialQueue = DispatchQueue(label: "registerStickerAsDownloaded_Queue", attributes: [])
    fileprivate static func registerStickerAsDownloaded(_ sticker: Sticker, word_id: String) {
        serialQueue.async { 
            let all_stickers = getDownloadedStickers()
            for a_sticker in all_stickers {
                if a_sticker.id == sticker.id {
                    return
                }
            }
            
            let stickers = getDownloadedStickersWithSuggestedWordId(word_id)
            var stickers_arr = [NSDictionary]()
            for a_sticker in stickers {
                stickers_arr.append(["sticker_id": a_sticker.id, "title": a_sticker.title, "filepath": a_sticker.filepath!])
            }
            stickers_arr.append(["sticker_id": sticker.id, "title": sticker.title, "filepath": sticker.filepath!])
            
            let userDefaults = UserDefaults.standard
            if let oldAllStickers = userDefaults.object(forKey: "downloadedStickers") as? NSDictionary {
                let newAllStickers = NSMutableDictionary(dictionary: oldAllStickers)
                newAllStickers.setObject(stickers_arr, forKey: word_id as NSCopying)
                userDefaults.set(newAllStickers, forKey: "downloadedStickers")
            }
            else {
                let newStickers = NSMutableDictionary()
                newStickers.setObject(stickers_arr, forKey: word_id as NSCopying)
                userDefaults.set(newStickers, forKey: "downloadedStickers")
            }
            userDefaults.synchronize()
        }
    }
    
    static func getDownloadedStickers() -> [Sticker] {
        var results = [Sticker]()
        let userDefault = UserDefaults.standard
        if let stickers = userDefault.object(forKey: "downloadedStickers") as? NSDictionary {
            for (_, sticker_infos) in stickers {
                let sticker_infos = sticker_infos as! NSArray
                for sticker_info in sticker_infos {
                    let sticker_info = sticker_info as! NSDictionary
                    results.append(Sticker(id: sticker_info["sticker_id"] as! String, title: sticker_info["title"] as! String, filepath: sticker_info["filepath"] as? String))
                }
            }
            return results
        }
        else {
            return results
        }
    }
    
    static func getDownloadedStickersWithSuggestedWordId(_ word_id: String) -> [Sticker] {
        var results = [Sticker]()
        let userDefault = UserDefaults.standard
        if let stickers = userDefault.object(forKey: "downloadedStickers") as? NSDictionary {
            for (_word_id, sticker_infos) in stickers {
                if (_word_id as! String) == word_id {
                    let sticker_infos = sticker_infos as! NSArray
                    for sticker_info in sticker_infos {
                        let sticker_info = sticker_info as! NSDictionary
                        results.append(Sticker(id: sticker_info["sticker_id"] as! String, title: sticker_info["title"] as! String, filepath: sticker_info["filepath"] as? String))
                    }
                }
            }
            return results
        }
        else {
            return results
        }
    }
    
    static let parseJsonFromServerSerialQueue = DispatchQueue(label: "parseJsonFromServerSerialQueue", attributes: [])
    static func parseJsonFromServer(_ suggestedWord_id: String, completion: @escaping ((_ error:NSError?, _ sticker_ids:[String]?)->())) {
        
        let pathRef = ShaprepicStorage.child(JsonInfoPath + suggestedWord_id + ".json")
        pathRef.downloadURL { (url, error) in
            if let url = url {
                parseJsonFromServerSerialQueue.async(execute: {
                    if let data = try? Data(contentsOf: url) {
                        let jsonObj = JSON(data: data)
                        if jsonObj != JSON.null {
                            var results = [String]()
                            for sticker_json in jsonObj.arrayValue {
                                if let sticker_id = sticker_json.string {
                                    results.append(sticker_id)
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                completion(nil, results)
                            })
                        }
                        else {
                            let str_print = "could not get json from \(url), make sure that file contains valid json."
                            let error = NSError(domain: str_print, code: 1, userInfo: nil)
                            completion(error, nil)
                        }
                    }
                    else {
                        
                    }
                })
            }
            else {
                completion(error as NSError?, nil)
            }
        }
    }
    
    /**
     @return suggestedWords(["word_id": word_id, "title": title]) which is completed, so it needs to be downloaded
    */
    static func checkCompletedStickers(_ user_id: String, completedSuggestedWords:@escaping ((_ error: NSError?,  _ suggestedWords:[NSDictionary])->())) {
        
        let ref = SharepicDataBase().child(SuggestedWordsTable).child(user_id)
        ref.observeSingleEvent(of: .value, with: { (dataSnap) in
            if dataSnap.exists() {
                let allWords = dataSnap.value as! NSDictionary
                var completedWords = [NSDictionary]()
                for (word_id, word_info) in allWords {
                    let word_id = word_id as! String
                    let word_info = word_info as! NSDictionary
                    if word_info["status"] as! String == SuggestedWordCompletedState {
                        completedWords.append(["id": word_id, "title": (word_info["suggestedWord"] as! String)])
                    }
                }
                completedSuggestedWords(nil, completedWords)
            }
            else {
                completedSuggestedWords(nil, [NSDictionary]())
            }
        })
        
    }
    
    static func setStickerUse(userID: String, stickersId: [String], completion: ((_ error: NSError?, _ ref: FIRDatabaseReference)->Void)?) {
        let table = SharePicUtil.SharepicDataBase().child(UseStickerTable)
        let timestamp = FIRServerValue.timestamp()
        let data: [NSObject: AnyObject] = ["userID" as NSObject: userID as AnyObject, "timestamp" as NSObject: timestamp as AnyObject]
        for stickerId in stickersId{
            table.child(stickerId + "/" + table.childByAutoId().key).updateChildValues(data) { (error, ref) in completion?(error as NSError?, ref)
            }
        }
    }
}
