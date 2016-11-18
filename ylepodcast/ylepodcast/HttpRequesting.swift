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
    var apiKeyLogin: String
    var opQueue = OperationQueue()
    
    init () {
        self.message = ""
        self.alertMessage = ""
        self.error = true
        self.done = false
        self.apiKey = ""
        self.apiKeyLogin = ""
        self.opQueue.maxConcurrentOperationCount = 1
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
    
    func setApiKeyLogin(apiKeyLogin: String) {
        self.apiKeyLogin = apiKeyLogin
    }
    
    func getMessage() -> String {
        return self.alertMessage
    }
    
    func getApiKey() -> String {
        return self.apiKey
    }
    
    func getApiKeyLogin() -> String {
        return self.apiKeyLogin
    }
    
    func getStatus() -> Bool {
        return self.done
    }
    
    func getError() -> Bool {
        return self.error
    }
    
    
    // Gets the apikey from the server
    func httpGetApi () {
        opQueue.addOperation({() -> Void in
            let sem = DispatchSemaphore(value: 0)
            
            let parameters: Parameters = ["username": "podcast", "password": "podcast16"]
            
            Alamofire.request("http://dev.mw.metropolia.fi/aanimaisema/plugins/api_auth/auth.php", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    // Set the apikey
                    self.setApiKey(apiKey: json["api_key"]!)
                    sem.signal()
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
            }
            
            sem.wait(timeout: DispatchTime.distantFuture)
        })
    }
    
    // Gets podcast from the server using apikey and category
    func httpGetPodCasts (parserObserver: DataParserObserver) {
        opQueue.addOperation({() -> Void in
            let sem = DispatchSemaphore(value: 0)
        print(self.getApiKey())
        //self.httpGetApi2()
        let parameters: Parameters = ["key": self.getApiKey(), "category": ""]
        var podcasts: [Podcast] = [Podcast]()
        
        Alamofire.request("http://dev.mw.metropolia.fi/aanimaisema/plugins/api_audio_search/index.php/", method: .get, parameters:parameters)
            .responseJSON{response in
                if let json = response.result.value {
                    if let array = json as? [Any] {
                        
                        for (_, item) in array.enumerated() {
                            if let details = item as? [[String:Any]] {
                                for (_, item) in details.enumerated() {
                                    
                                let tags = item["Tags"] as? String ?? ""
                                let cName = item["Collection name"] as? String ?? ""
                                let duration = item["Length (sec)"] as? String ?? ""
                                let description = item["Description"] as? String ?? ""
                                let photo = UIImage(named: "defaultImage")!
                                    
                                let podcast = Podcast(collection: cName, photo: photo, description: description, duration: duration, tags: [tags])
                                podcasts.append(podcast!)
                                
                                parserObserver.podcastsParsed(podcasts: podcasts)
                                
                                sem.signal()
                                }
                                //let collection = details[0]["Collection name"]
                                //let description = details[0]["Description"]
                                //let duration = details[0]["Length (sec)"]
                                    }
                        }
                        
                        
                    }
                }else{
                    print("Ei mene if lauseen läpi")
                }
        }
            sem.wait(timeout: DispatchTime.distantFuture)
        })
    }
    
    // Hae Apikey 2 backendista.
    func httpGetApi2 () {
        let parameters: Parameters = ["username": "moi", "password": "heps"]
        
        Alamofire.request("http://media.mw.metropolia.fi/arsu/login", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    // Set the apikey
                    self.setApiKeyLogin(apiKeyLogin: json["token"]!)
                    print(self.getApiKeyLogin())
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }
    
    func addUser(){
        let parameters: Parameters = ["username": "moi", "password": "heps"]
        Alamofire.request("http://82.196.15.60:8081/attend/",method: .post, parameters: parameters,encoding: JSONEncoding.default)
            .responseJSON{response in
                if let httpStatusCode = response.response?.statusCode {
                    print(httpStatusCode)
                    switch(httpStatusCode) {
                    case 200:
                        self.error = false
                        self.message = ""
                        break
                    default:
                        self.message = "Oops! Something went wrong. Try again later."
                        break
                    }
                } else {
                    //message = error.localizedDescription
                }
                //self.setMessage(self.message)
                //self.setError(self.error)
                //self.viewController.shouldPerformSegueWithIdentifier("SignIn", sender: self)
        }
        
    }
    }

