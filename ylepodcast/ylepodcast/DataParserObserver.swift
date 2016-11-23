//
//  DataParsersObserver.swift
//  ylepodcast
//
//  Created by Arto Heino on 10/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation

protocol DataParserObserver {
    
    func podcastsParsed (podcasts: [Podcast])

}
