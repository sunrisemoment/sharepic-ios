//
//  AlbumNameCell.swift
//  PalPic
//
//  Created by Daniel Suciu on 18/10/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit

class AlbumNameCell: UITableViewCell {

    @IBOutlet weak var lblAlbumName: UILabel!
    @IBOutlet weak var lblContentNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
