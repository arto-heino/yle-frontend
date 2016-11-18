//
//  HttpRequesting.swift
//  ylepodcast
//
//  Created by Arto Heino on 07/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class HttpRequesting {
    
    var message: String
    var apiKey: String
    var alertMessage: String
    var error: Bool
    var done: Bool
    
    init () {
        self.message = ""
        self.alertMessage = ""
        self.error = true
        self.done = false
        self.apiKey = ""
    }
    
    func setMessage(statusMessage: String) {
        self.alertMessage = statusMessage
    }
    
    func setStatus(status: Bool) {
        self.done = status
    }
    
    func setError(error: Bool) {
        self.error = error
    }
    
    func setApiKey(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getMessage() -> String {
        return self.alertMessage
    }
    
    func getApiKey() -> String {
        return self.apiKey
    }
    
    func getStatus() -> Bool {
        return self.done
    }
    
    func getError() -> Bool {
        return self.error
    }
    
    
    // Gets the apikey from the server
    func httpGetApi () {
        
        let parameters: Parameters = ["username": "podcast", "password": "podcast16"]
    
        Alamofire.request("http://dev.mw.metropolia.fi/aanimaisema/plugins/api_auth/auth.php", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    // Set the apikey
                    self.setApiKey(apiKey: json["api_key"]!)
                    print(self.getApiKey())
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }
    
    // Gets podcast from the server using apikey and category
    func httpGetPodCasts (parserObserver: DataParserObserver) {
        let parameters2: Parameters = ["app_id": "9fb5a69d", "app_key": "100c18223e4a9346ee4a7294fb3c8a1f", "availability": "ondemand","mediaobject": "audio", "order": "playcount.24h:desc"]
        var podcasts: [Podcast] = [Podcast]()
        
        Alamofire.request("https://external.api.yle.fi/v1/programs/items.json", method: .get, parameters:parameters2, encoding: URLEncoding.default)
            .responseJSON{response in
                if let json = response.result.value {
                    print(json)
                    if let array = json as? [Any] {
                        
                        for (_, item) in array.enumerated() {
                            if let details = item as? [[String:Any]] {
                                for (_, item) in details.enumerated() {
                                    
                                let tags = item["Tags"] as? String ?? ""
                                let cName = item["Collection name"] as? String ?? ""
                                let duration = item["Length (sec)"] as? String ?? ""
                                let description = item["Description"] as? String ?? ""
                                let photo = UIImage(named: "defaultImage")!
                                let pUrl = item["Download link"] as? String ?? ""
                                    
                                    let podcast = Podcast(collection: cName, photo: photo, description: description, duration: duration, tags: [tags], url: pUrl)
                                        
                                podcasts.append(podcast!)
                                    
                                    
                                }
                                //let collection = details[0]["Collection name"]
                                //let description = details[0]["Description"]
                                //let duration = details[0]["Length (sec)"]
                            }
                            
                        }
                        parserObserver.podcastsParsed(podcasts: podcasts)
                        
                        
                    }
                }else{
                    print("Ei mene if lauseen läpi")
                }
        }
    }
}
