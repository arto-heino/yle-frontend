//
//  SearchItemTableViewCell.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 09/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class SearchItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var podcastImage: UIImageView!

   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
