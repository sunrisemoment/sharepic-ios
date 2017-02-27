//
//  StickerResultCollectionViewCell.swift
//  sharepic
//
//  Created by steven on 21/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit

class StickerResultCollectionViewCell: UICollectionViewCell {
    
    var sticker: Sticker! {
        didSet {
            imgSticker.image = sticker.image
            imgSticker.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var imgSticker: UIImageView!
    
}
