//
//  Podcast.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 02/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit


class Podcast: Hashable {
    
    var collection: String
    var photo: UIImage
    var description: String
    var duration: String
    var tags = [String]()
    
    
    init? (collection: String, photo: UIImage, description: String, duration: String, tags:  [String]) {
        
        self.collection = collection
        self.photo = photo
        self.description = description
        self.duration = duration
        self.tags = tags
        
    }
    
    var hashValue : Int {
        get {
            return "\(self.collection),\(self.description)".hashValue
        }
    }
    
}

func ==(lhs: Podcast, rhs: Podcast) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
