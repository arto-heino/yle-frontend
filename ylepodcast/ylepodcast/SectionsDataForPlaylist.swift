//
//  SectionsDataForPlaylist.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 23/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation

class SectionsDataForPlaylist {
    
    func getSectionsFromData() -> [Section] {
        var sectionsArray = [Section]()
        
        let myPodcasts = Section(title: "Omat", objects: ["Siivouslista", "Lista lenkille"])
        let recommended = Section(title: "Valmiit", objects: ["Yle Puhe", "Aamulypsy"])
        let favorites = Section(title: "Suosikit", objects: ["Suosikki 1", "Suosikki 2", "Suosikki 3"])
        
        
        sectionsArray.append(myPodcasts)
        sectionsArray.append(recommended)
        sectionsArray.append(favorites)
        
        return sectionsArray
    }
}
