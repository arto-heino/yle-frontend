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
import CoreData

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
        let parameters2: Parameters = ["app_id": "9fb5a69d", "app_key": "100c18223e4a9346ee4a7294fb3c8a1f", "availability": "ondemand","mediaobject": "audio", "order": "playcount.6h:desc", "limit":"80", "type": "radiocontent", "contentprotection": "22-0,22-1" ]
        
        Alamofire.request("https://external.api.yle.fi/v1/programs/items.json", method: .get, parameters:parameters2, encoding: URLEncoding.default)
            .responseJSON{response in
                if let json = response.result.value {
                    if let array = json as? [String:Any]{
                        if let details = array["data"] as? [[String:Any]] {
                            for (_, item) in details.enumerated() {
                                let tags = item["tags"] as? [String:Any] 
                                let cName = item["title"] as? [String:Any]
                                let duration = item["duration"] as? String ?? ""
                                let description = item["description"] as? [String:Any]
                                let photo = item["defaultImage"] as? String ?? ""
                                let pUrl = item["Download link"] as? String ?? ""
                                let pubEv = item["publicationEvent"] as? [[String:Any]]
                                let program_id = item["id"] as? String ?? ""
                                for (_, event) in (pubEv?.enumerated())! {
                                    let status = event["temporalStatus"] as? String ?? ""
                                    let type = event["type"] as? String ?? ""
                                    if status == "currently" && type == "OnDemandPublication" {
                                        let media = event["media"] as? [String:Any]
                                        let media_id = media?["id"]
                                        
                                        let params: Parameters = ["program_id": program_id, "media_id": media_id!, "protocol": "PMD", "app_id": "9fb5a69d", "app_key": "100c18223e4a9346ee4a7294fb3c8a1f"]
                                        print(params)
                                        Alamofire.request("https://external.api.yle.fi/v1/media/playouts.json", method: .get, parameters:params, encoding: URLEncoding.default).responseJSON{response in
                                            print(response.result)
                                                if let json = response.result.value {
                                                    print(json)
                                                } else {
                                                    print("Shit happens")
                                                }
                                            }
                                    }
                                }
                                
                                let podcast = NSEntityDescription.insertNewObject(forEntityName: "Podcast", into: AppDelegate.moc) as! Podcast

                                podcast.podcastCollection = cName!
                                podcast.podcastImageURL = photo
                                podcast.podcastDescription = description
                                podcast.podcastDuration = duration
                                podcast.podcastTags = tags
                                podcast.podcastURL =  pUrl
                                
                                AppDelegate.addPodcastToCoreData(podcast: podcast)
                    
                            }
                        }
                     
                        parserObserver.podcastsParsed(podcasts: AppDelegate.fetchPodcastsFromCoreData())
                    }
                }else{
                    print("Ei mene if lauseen läpi")
                }
        }
    }
    
    func httpGetFromBackend (url:String!, token: String!, completion:@escaping ([Any]) -> Void) {

        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        Alamofire.request(url, method: .get, headers:headers)
            .responseJSON{response in
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        if let data = response.result.value as? [Any]{
                            completion(data)
                            return
                        }
                    default:
                        if let data = response.result.value as? [Any]{
                            completion(data)
                            return
                        }
                    }
                }else{
                    self.setMessage(statusMessage: "Something went wrong.")
                }
        }
    }

}
