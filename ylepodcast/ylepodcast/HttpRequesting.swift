//
//  HttpRequesting.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation
import Alamofire

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
    
    
    func httpGetApi () {
        
        let parameters: Parameters = ["username": "podcast", "password": "podcast16"]
        
        Alamofire.request("http://dev.mw.metropolia.fi/aanimaisema/plugins/api_auth/auth.php", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    self.setApiKey(apiKey: json["api_key"]!)
                    self.httpGetPodCasts()
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }
    
    func httpGetPodCasts () {
        let parameters: Parameters = ["key": self.getApiKey(), "category": ""]
        
        Alamofire.request("http://dev.mw.metropolia.fi/aanimaisema/plugins/api_audio_search/index.php/", method: .get, parameters:parameters)
            .responseJSON{response in
                if let json = response.result.value {
                    if let array = json as? [Any] {
                        
                        for (_, item) in array.enumerated() {
                            if let details = item as? [[String:Any]] {
                                let title = details[0]["Original filename"]
                                
                                print(title ?? "tyhjä")
                            }
                        }
                    
                    
                    }
                }else{
                    print("ei toimi")
                }
        }

    }
}
