//
//  DataParsersObserver.swift
//  ylepodcast
//
//  Created by Arto Heino on 10/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation

protocol DataParserObserver {
    
    static var apiKeyServer: Int { get set }
    static var ApiKeyPodcast: Int { get set }
    
    func podcastsParsed (podcasts: [Podcast])
    func apiKey_podcast (apikey1: String)
    func apiKey_server (apikey2: String)

}
