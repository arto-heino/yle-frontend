//
//  HttpRequesting.swift
//  ylepodcast
//
//  Created by Arto Heino on 07/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

// FIXME: Need to move some of the functions to new helper class?

import Foundation
import Alamofire
import UIKit
import CoreData
import CryptoSwift

class HttpRequesting {
    
    var cryptKey: String
    
    init () {
        
        let path = Bundle.main.path(forResource: "settings", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as! [String:String]
        self.cryptKey = dict["podcastDecryptKey"]!
    }
    
    // Gets the apikey from the metropolia aanimaisema server
    /*
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
  */
    
    // MARK: - PODCASTS
    // Parse podcast from the YLEAPI using appkey, appid, availability, mediaobject, order, limit, type and contentprotection. Returns Podcast Array
    // FIXME: Contains lots of useless parsing
    
    func httpGetPodCasts () {
        
        var podcastArray: [[String : Any?]] = []
        
        let parametersToYle: Parameters = ["app_id": "9fb5a69d", "app_key": "100c18223e4a9346ee4a7294fb3c8a1f", "availability": "ondemand","mediaobject": "audio", "order": "playcount.6h:desc", "limit":"50", "type": "radioprogram", "contentprotection": "22-0,22-1" ]
        
        Alamofire.request("https://external.api.yle.fi/v1/programs/items.json", method: .get, parameters:parametersToYle, encoding: URLEncoding.default)
            .responseJSON{response in
                if let json = response.result.value {
                    if let array = json as? [String:Any]{
                        if let details = array["data"] as? [[String:Any]] {
                            for (_, item) in details.enumerated() {
                                let pubEv = item["publicationEvent"] as? [[String:Any]]
                                for (_, event) in (pubEv?.enumerated())! {
                                    let status = event["temporalStatus"] as? String ?? ""
                                    let type = event["type"] as? String ?? ""
                                    if status == "currently" && type == "OnDemandPublication" {
                                        let media = event["media"] as? [String:Any]
                                        let media_id = media?["id"] as? String ?? ""
                                        let title = item["title"] as! [String:Any]
                                        let duration = item["duration"] as? String ?? ""
                                        let description = item["description"] as! [String:Any]
                                        let series = item["partOfSeries"] as! [String:Any]
                                        let seriesID = series["id"] as? String ?? "No series ID."
                                        let seriesTitles = series["title"] as! [String:Any]
                                        let seriesTitle = seriesTitles["fi"] as? String ?? "No series title."
                                        let program_id = item["id"] as? String ?? ""
                                        let parsedDuration = self.parseDuration(duration: duration)
                                        let subject = item["subject"] as? [[String:Any]]
                                        
                                        var categoryArray = [String]()
                                        for (_, subject) in (subject?.enumerated())!{
                                            let cat = subject["title"] as! [String:String]
                                            if categoryArray.contains(cat["fi"]!) {
                                            }else{
                                                categoryArray.append(cat["fi"]!)
                                            }
                                        }
                                        
                                        var podcastItem = [String : Any?]()
                                        podcastItem["podcastCategories"] = categoryArray
                                        podcastItem["podcastTitle"] = title["fi"] as! String? ?? "Ei nimeä"
                                        podcastItem["podcastMediaID"] = media_id
                                        podcastItem["podcastID"] = program_id
                                        podcastItem["podcastDescription"] = description["fi"] as! String? ?? "Ei kuvausta"
                                        podcastItem["podcastDuration"] = parsedDuration
                                        podcastItem["seriesTitle"] = seriesTitle
                                        podcastItem["seriesID"] = seriesID
                                        
                                        let image = item["image"] as? [String:Any]
                                        if image!["id"] != nil {
                                            var imageURL = "http://images.cdn.yle.fi/image/upload/w_240,h_240,c_fit/"
                                            imageURL.append((image?["id"] as? String)!)
                                            imageURL.append(".png")
                                            podcastItem["imageURL"] = imageURL
                                        }
                                        if podcastItem["podcastTitle"] as! String != "Ei nimeä" {
                                            podcastArray.append(podcastItem)
                                        }
                                    }
                                }

                            }
                        }
                    }
                    // Send the Podcast array to url check
                    self.checkPodcastAvailability(podcastArray: podcastArray)
                    
                } else{
                    print("Error when parsing from YLEAPI!")
                }
        }
    }
    
    // Check the podcast availability (program_id, media_id, protocol, app_id, app_key), is it possible to play the podcast. Add the playable podcasts to CoreData
    
    func checkPodcastAvailability(podcastArray: Array<[String : Any?]>) {
        
        for podcastItem in podcastArray {
            let parametersToYle: Parameters = ["program_id": podcastItem["podcastID"]!!, "media_id": podcastItem["podcastMediaID"]!!, "protocol": "PMD", "app_id": "9fb5a69d", "app_key": "100c18223e4a9346ee4a7294fb3c8a1f"]
            
            Alamofire.request("https://external.api.yle.fi/v1/media/playouts.json", method: .get, parameters:parametersToYle, encoding: URLEncoding.default).responseJSON{response in

                // If response from the server is not nil, the podcast is playable.
                if response.result.value != nil {
                    let context = DatabaseController.getContext()
                    let podcast = Podcast(context: context)
                    
                    if podcastItem["imageURL"] != nil {
                        self.getPodcastImage(context: context, podcast: podcast, url: podcastItem["imageURL"] as! String)
                    }
                    
                    podcast.podcastTitle = podcastItem["podcastTitle"]! as! String?
                    podcast.podcastDescription = podcastItem["podcastDescription"]! as! String?
                    podcast.podcastDuration = Int64(podcastItem["podcastDuration"]! as! Int)
                    podcast.podcastMediaID = podcastItem["podcastMediaID"]! as? String
                    podcast.podcastCollection = podcastItem["seriesTitle"]! as? String
                    podcast.podcastCollectionID = podcastItem["seriesID"]! as? String
                    
                    let cat = podcastItem["podcastCategories"] as! [String]
                    
                    for(_, tag) in cat.enumerated(){
                        let category = Category(context: context)
                        category.categoryTag = tag
                        category.addToPodcast(podcast)
                    }
                    
                    // Modify the podcast id to int, remove -
                    let modifiedID = (podcastItem["podcastID"] as AnyObject).replacingOccurrences(of: "-", with: "")
                    let podcastID = Int64(modifiedID)
                
                    podcast.podcastID = podcastID!
                
                    DatabaseController.saveContext()
                
                } else {
                    // Could not play the podcast, delete it.
                }

            }
        }
    }
    
    func getPodcastImage(context: NSManagedObjectContext, podcast: Podcast, url: String) {
        
        Alamofire.request(url).response { response in
            if let data = response.data {
                let imageDataArray = [UInt8](data)
                let imageData = NSData(bytes: imageDataArray, length: imageDataArray.count)
                podcast.podcastImage = imageData

                DatabaseController.saveContext()
            }
        }
        
    }
    
    // Parse the podcast duration to minutes
    func parseDuration(duration: String) -> Int {
        
        var pSeconds = 0
        var pMinutes = 0
        var pHours = 0
        let secIdx = duration.characters.index(of: "S")
        let minIdx = duration.characters.index(of: "M")
        let hIdx = duration.characters.index(of: "H")
        let tIdx = duration.characters.index(of: "T")
        if hIdx != nil {
            let range = duration.index(after: tIdx!)..<hIdx!
            let hours = duration.substring(with: range)
            pHours = Int(hours)!
        }
        if minIdx != nil {
            if hIdx != nil {
                let range = duration.index(after: hIdx!)..<minIdx!
                let minutes = duration.substring(with: range)
                pMinutes = Int(minutes)!
            } else {
                let range = duration.index(after: tIdx!)..<minIdx!
                let minutes = duration.substring(with: range)
                pMinutes = Int(minutes)!
            }
        }
        if secIdx != nil {
            if minIdx != nil {
                let range = duration.index(after: minIdx!)..<secIdx!
                let seconds = duration.substring(with: range)
                pSeconds = Int(seconds)!
            } else if hIdx != nil {
                let range = duration.index(after: hIdx!)..<secIdx!
                let seconds = duration.substring(with: range)
                pSeconds = Int(seconds)!
            } else {
                let range = duration.index(after: tIdx!)..<secIdx!
                let seconds = duration.substring(with: range)
                pSeconds = Int(seconds)!
            }
        }
        let parsedDuration = pHours*3600 + pMinutes*60 + pSeconds
        return parsedDuration
    }
    
    func secondsToTimeString(seconds: Int64) -> String {
        //let hours = seconds / 3600
        let minutes = "\((seconds) / 60)"
        var secondsString = "\((seconds % 3600) % 60)"
        if secondsString.characters.count < 2 {
            secondsString = "0" + secondsString
        }
        let timeString = minutes + ":" + secondsString
        
        return timeString
    }

    
    // MARK: - BACKEND
    // Helper function to get data from backend (url, token) return AnyObject of response
    func httpGetFromBackend (url:String!, token: String!, completion:@escaping (AnyObject) -> Void) {
        
        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        
        Alamofire.request(url, method: .get, headers:headers)
            .responseJSON{response in
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        if let data = response.result.value{
                            completion(data as AnyObject)
                            return
                        }
                    default:
                        // Should cast an error if the get don´t complete
                        if let data = response.result.value{
                            completion(data as AnyObject)
                            return
                    }
                }
            }
        }
    }

    // MARK: - ENCRYPT
    // Probably need to move to new class?
    
    // Get the podcast url and decrypt it (program_id, media_id, protocol, app_id, app_key). Returns decrypted url which can be played
    func getAndDecryptUrl(podcast: Podcast, urlDecryptObserver: UrlDecryptObserver) {
        
        var dec_url = ""
        var podcastID:String {
            return "\(podcast.podcastID)"
        }
        let substr1 = podcastID.substring(to: podcastID.index(after: podcastID.startIndex)).appending("-")
        let substr2 = podcastID.substring(from: podcastID.index(after: podcastID.startIndex))
        let programID = substr1 + substr2
        let params: Parameters = ["program_id": programID, "media_id": podcast.podcastMediaID!, "protocol": "PMD", "app_id": "9fb5a69d", "app_key": "100c18223e4a9346ee4a7294fb3c8a1f"]
        
        Alamofire.request("https://external.api.yle.fi/v1/media/playouts.json", method: .get, parameters:params, encoding: URLEncoding.default).responseJSON{response in
            if let json = response.result.value {
                if let array = json as? [String:Any]{
                    if let details = array["data"] as? [[String:Any]] {
                        let item = details[0]
                        let enc_url = item["url"] as? String ?? ""
                        let decodedData = Data(base64Encoded: enc_url, options:NSData.Base64DecodingOptions(rawValue: 0))
                        let decodedArray = [UInt8](decodedData!)
                        
                        let iv = Array(decodedArray[0 ... 15])
                        let message = Array(decodedArray[16 ..< (decodedArray.count)])
                        
                        let key = self.cryptKey
                        let keyData = key.data(using: .utf8)!
                        let decodedKeyArray = [UInt8](keyData)
                        
                        dec_url = self.aesDecrypt(key: decodedKeyArray, iv: iv, message: message)
                    }
                }
                // Send the decrypted url to observer and start playing the podcast
                urlDecryptObserver.urlDecrypted(url: dec_url)
            } else {
                // Can´t decrypt the url, should cast an error to user and delete podcast?
            }
        }
    }
    
    func base64ToByteArray(base64String: String) -> [UInt8]? {
        
        if let nsdata = NSData(base64Encoded: base64String, options: []) {
            var bytes = [UInt8](repeating: 0, count: nsdata.length)
            nsdata.getBytes(&bytes, length: bytes.count)
            return bytes
        }
        return nil // Invalid input
    }
    
    func aesDecrypt(key: Array<UInt8>, iv: Array<UInt8>, message: Array<UInt8>) -> String {
        
        var result: NSString = ""
        do {
            let decrypted:[UInt8] = try AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).decrypt(message)
            let decData = NSData(bytes: decrypted, length: Int(decrypted.count))
            result = NSString(data: decData as Data, encoding: String.Encoding.utf8.rawValue)!
        } catch {
            // What it should print? Warn user?
            print(error)
        }
        return String(result)
    }
    
}
