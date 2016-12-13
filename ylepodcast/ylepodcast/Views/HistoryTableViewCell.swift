//
//  HistoryTableViewCell.swift
//  ylepodcast
//
//  Created by Arto Heino on 12/12/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var podcastImageView: UIImageView!
    
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    @IBOutlet weak var durationLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
