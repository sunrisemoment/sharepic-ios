//
//  CommonUtil.swift
//  findtalents
//
//  Created by steven on 14/4/2016.
//  Copyright © 2016 steven. All rights reserved.
//

import Foundation
import UIKit

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

class CommonUtil: AnyObject {
    
    /**
    @param albumName may be anything of user album name such as "Skype" or "Downloads", "Baby Story", "Dropbox" or "Instagram". not "Camera Roll", "Screenshots" or "Recently Deleted" since these are not album
    */
    static func getSyncPhotosForAlbum(_ albumName: String, searchCompletion: ((_ albumFound: Bool, _ photoCount: Int)->Void)?, enumerateHandler: ((PHAsset) -> Void)?)
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        var assetCollection: PHAssetCollection!
        var albumFound: Bool = false
        var photoAssets: PHFetchResult<PHAsset>!
        
        if let _:AnyObject = collection.firstObject{
            //found the album
            assetCollection = collection.firstObject! as PHAssetCollection
            albumFound = true
        }
        else { albumFound = false }
        
        if !albumFound {
            searchCompletion?(false, 0)
            return
        }
        
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        searchCompletion?(true, photoAssets.count)
        
        if enumerateHandler == nil {
            return
        }
        
//        let imageManager = PHCachingImageManager()
        
        photoAssets.enumerateObjects({ (object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                
//                let imageSize = CGSize(width: asset.pixelWidth,
//                    height: asset.pixelHeight)
//                
//                /* For faster performance, and maybe degraded image */
//                let options = PHImageRequestOptions()
//                options.deliveryMode = .FastFormat
//                options.synchronous = true
//                imageManager.requestImageForAsset(asset,
//                    targetSize: imageSize,
//                    contentMode: .AspectFill,
//                    options: options,
//                    resultHandler: {
//                        image, info in
//                        enumerateHandler?(image, asset, info)
//                })
                enumerateHandler?(asset)
            }
        })
    }
    
    static func getSyncPhotosForCameraRoll(_ ascendingByCreationDate: Bool = true, searchCompletion: ((_ photoCount: Int)->Void)?, enumerateHandler: ((PHAsset) -> Void)?) {
        
        let ascending = PHFetchOptions()
        ascending.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascendingByCreationDate)]
        
        let photoAssets = PHAsset.fetchAssets(with: .image, options: ascending)
        searchCompletion?(photoAssets.count)
        
        if enumerateHandler == nil {
            return
        }
        
//        let imageManager = PHCachingImageManager()
        photoAssets.enumerateObjects ({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                
//                let imageSize = CGSize(width: asset.pixelWidth,
//                    height: asset.pixelHeight)
//                
//                /* For faster performance, and maybe degraded image */
//                let options = PHImageRequestOptions()
//                options.deliveryMode = .FastFormat
//                options.synchronous = true
//                imageManager.requestImageForAsset(asset,
//                    targetSize: imageSize,
//                    contentMode: .AspectFill,
//                    options: options,
//                    resultHandler: {
//                        image, info in
//                        enumerateHandler?(asset, info)
//                })
                enumerateHandler?(asset)
            }
        })
    }
    
    static func getSyncPhotosForScreenshots(_ searchCompletion: ((_ photoCount: Int)->Void)?, enumerateHandler: ((PHAsset) -> Void)?) {
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var screenshots: PHAssetCollection?
        
        collections.enumerateObjects ({
            (collection, _, _) -> Void in
            if collection.localizedTitle == "Screenshots" {
                screenshots = collection as PHAssetCollection
                let photoAssets = PHAsset.fetchAssets(in: screenshots!, options: nil)
                searchCompletion?(photoAssets.count)
                
                if enumerateHandler == nil {
                    return
                }
                
//                let imageManager = PHCachingImageManager()
                photoAssets.enumerateObjects ({(object: AnyObject!,
                    count: Int,
                    stop: UnsafeMutablePointer<ObjCBool>) in
                    
                    if object is PHAsset{
                        let asset = object as! PHAsset
//
//                        let imageSize = CGSize(width: asset.pixelWidth,
//                            height: asset.pixelHeight)
//                        
//                        /* For faster performance, and maybe degraded image */
//                        let options = PHImageRequestOptions()
//                        options.deliveryMode = .FastFormat
//                        options.synchronous = true
//                        imageManager.requestImageForAsset(asset,
//                            targetSize: imageSize,
//                            contentMode: .AspectFill,
//                            options: options,
//                            resultHandler: {
//                                image, info in
//                                enumerateHandler?(image, asset, info)
//                        })
                        enumerateHandler?(asset)
                    }
                })
            }
        })
    }
    
    static func getSyncPhotosForRecentlyDeleted() {
        
    }
    
    static func getAllAlbumNames(_ enumerateHandler: @escaping ((_ albumname: String)->Void)) {
        let userAlbumOptions = PHFetchOptions()
//        userAlbumOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any , options: userAlbumOptions)
        userAlbums.enumerateObjects ({ (collection, idx, stop) in
            enumerateHandler(collection.localizedTitle!)
        })
    }
    
    static func getAllAlbumNamesAndCounts(_ enumerateHandler: @escaping ((_ albumname: String , _ count : Int)->Void)) {
        
        let fetchOptions = PHFetchOptions()
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any , options: fetchOptions)
        userAlbums.enumerateObjects ({ (collection, idx, stop) in
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            enumerateHandler(collection.localizedTitle!, collection.estimatedAssetCount)
        })
    }
    
    static func getSmartAllbums(_ enumerateHandler: @escaping ((_ albumname: String , _ count : Int)->Void)) {
        
        let fetchOptions = PHFetchOptions()
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any , options: fetchOptions)
        userAlbums.enumerateObjects ({ (collection, idx, stop) in
            enumerateHandler(collection.localizedTitle!, collection.estimatedAssetCount)
        })
    }

    
    static func fetchVideoFromLibrary() {
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        fetchResult.enumerateObjects ({ (object, index, stop) -> Void in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestAVAsset(forVideo: object, options: .none) { (avAsset, avAudioMix, dict) -> Void in
                print(avAsset)
            }
        })
    }
    
    //MARK: - NSAttributeString
    static func attributedString(_ string: String, font: UIFont, textColor: UIColor) -> NSAttributedString {
        let attr = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        return NSAttributedString(string: string, attributes: attr)
    }
}
