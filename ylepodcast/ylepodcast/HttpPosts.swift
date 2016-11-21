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

class HttpPosts {
    
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
        self.apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywidXNlcm5hbWUiOiJtb2kiLCJlbWFpbCI6Im1vaUBleGFtcGxlLmNvbSIsImlzX2FkbWluIjpudWxsLCJkYXRlIjoiMjAxNi0xMS0xNVQxNjowMToyMy4wMDBaIiwiaWF0IjoxNDc5NTY5MDg0LCJleHAiOjE1MTExMDUwODR9.O-jbrwYvShTRmKKDawKBexL2YwpGPMKv3OsyvZJJrig"
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
    
    func httpGetApi2 () {
        let parameters: Parameters = ["username": "moi", "password": "heps"]
        
        Alamofire.request("http://media.mw.metropolia.fi/arsu/login", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    // Set the apikey
                    print("onnistui")
                    self.registerNewUser()
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }
    
    func registerNewUser () {
        let parameters: Parameters = ["username": "artoh", "password": "siika1", "email": "arto.siika@siika.fi", "token": getApiKey()]
        Alamofire.request("http://media.mw.metropolia.fi/arsu/users", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    print(json)
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }
    
    func loginUser () {
        let parameters: Parameters = ["token": getApiKey(), "username": "moi", "password": "heps"]
        
        Alamofire.request("http://media.mw.metropolia.fi/arsu/login", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let json = response.result.value as? [String: String] {
                    // Set the apikey
                    print(json["token"] ?? "Ei apia")
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }
    
}
