//
//  UsersPlaylistTableViewCell.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 29/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class UsersPlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var itemsInPlaylistLabel: UILabel!
    
    @IBOutlet weak var ownPlaylistLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
