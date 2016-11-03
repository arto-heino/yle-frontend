//
//  PodcastsTableViewCell.swift
//  ylepodcast
//
//  Created by Arto Heino on 03/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class PodcastsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
