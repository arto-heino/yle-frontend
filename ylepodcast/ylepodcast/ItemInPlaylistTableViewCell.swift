//
//  ItemInPlaylistTableViewCell.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 01/12/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class ItemInPlaylistTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var collectionInPlaylistLabel: UILabel!
    @IBOutlet weak var titleInPlaylistLabel: UILabel!

    @IBOutlet weak var durationInPlaylistLabel: UILabel!
    
    @IBOutlet weak var podcastImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
