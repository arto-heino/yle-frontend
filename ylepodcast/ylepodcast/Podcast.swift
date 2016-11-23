//
//  Podcast.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 02/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class Podcast: NSManagedObject {
    
    @NSManaged public var podcastCollection: [String: Any]?
    @NSManaged public var podcastDescription: [String: Any]?
    @NSManaged public var podcastTags: [String: Any]?
    @NSManaged public var podcastID: Int64
    @NSManaged public var podcastURL: String?
    @NSManaged public var podcastImageURL: String?
    @NSManaged public var podcastCollectionID: Int64
    @NSManaged public var podcastDuration: String?
    @NSManaged public var podcastTitle: [String: Any]?
    
}



//class Podcast: Hashable {
//    
//    var collection: [String:Any]
//    var photo: UIImage
//    var description: [String:Any]
//    var duration: String
//    var tags = [String]()
//    var url: String
//    
//    init? (collection: [String:Any], photo: UIImage, description: [String:Any], duration: String, tags:  [String], url: String) {
//        
//        self.collection = collection
//        self.photo = photo
//        self.description = description
//        let replaced = duration.replacingOccurrences(of: " ", with: "+")
//        self.duration = replaced
//        self.tags = tags
//        self.url = url
//    }
//
//    //tekee collectionista ja descriptionista uniikin hashValuen
//    var hashValue : Int {
//        get {
//            return "\(self.collection),\(self.description)".hashValue
//        }
//    }
//    
//}
//
////vertailu kahden hashvaluen välillä
//func ==(lhs: Podcast, rhs: Podcast) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//}
