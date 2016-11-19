//
//  Podcast.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 02/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit


class Podcast: Hashable {
    
    var collection: [String:Any]
    var photo: UIImage
    var description: [String:Any]
    var duration: String
    var tags = [String]()
    var url: String
    
    init? (collection: [String:Any], photo: UIImage, description: [String:Any], duration: String, tags:  [String], url: String) {
        
        self.collection = collection
        self.photo = photo
        self.description = description
        let replaced = duration.stringByReplacingOccurrencesOfString(" ", withString: "+", options: nil, range: nil)
        self.duration = replaced
        self.tags = tags
        self.url = url
    }

    //tekee collectionista ja descriptionista uniikin hashValuen
    var hashValue : Int {
        get {
            return "\(self.collection),\(self.description)".hashValue
        }
    }
    
}

//vertailu kahden hashvaluen välillä
func ==(lhs: Podcast, rhs: Podcast) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
