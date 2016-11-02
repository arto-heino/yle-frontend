//
//  Podcast.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 02/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit


class Podcast {
    
    var collection: String
    var photo: UIImage?
    var description: String
    var duration: String


    init? (collection: String, photo: UIImage?, description: String, duration: String) {
        
        self.collection = collection
        self.photo = photo
        self.description = description
        self.duration = duration
    
}
}
