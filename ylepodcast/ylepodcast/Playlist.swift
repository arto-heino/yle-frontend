//
//  Playlist.swift
//  ylepodcast
//
//  Created by Arto Heino on 24/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Playlist: NSManagedObject {
    
    @NSManaged public var playlistID: Int64
    @NSManaged public var playlistName: String?
    @NSManaged public var playlistUserID: Int64
}
