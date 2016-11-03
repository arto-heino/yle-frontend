//
//  Podcast.swift
//  ylepodcast
//
//  Created by Arto Heino on 03/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
class Podcast {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?) {
        self.name = name
        self.photo = photo
        
        if name.isEmpty {
            return nil
        }
    }
}
