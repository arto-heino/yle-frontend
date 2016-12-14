//
//  PlaylistTableViewCell.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 23/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var myPlaylistNameLabel: UILabel!
    

    @IBOutlet weak var myItemsInPlaylist: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
