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
    var userKey: String
    var alertMessage: String
    var error: Bool
    var done: Bool
    
    init () {
        self.message = ""
        self.alertMessage = ""
        self.error = true
        self.done = false
        self.userKey = ""
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
    
    func setUserKey(userKey: String) {
        self.userKey = userKey
    }
    
    func getMessage() -> String {
        return self.alertMessage
    }
    
    func getUserKey() -> String {
        return self.userKey
    }
    
    func getStatus() -> Bool {
        return self.done
    }
    
    func getError() -> Bool {
        return self.error
    }
    
    func httpLogin (username:String, password: String, completion:@escaping (Bool) -> Void) {
        let parameters: Parameters = ["username": username, "password": password]
        
        Alamofire.request("http://media.mw.metropolia.fi/arsu/login", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        if let data = response.result.value as? [String: String]{
                            self.message = data["message"]!
                            self.setUserKey(userKey: data["token"]!)
                            let preferences = UserDefaults.standard
                            preferences.set(self.getUserKey(), forKey: "userKey")
                            preferences.set(username, forKey: "userName")
                        }
                        completion(true)
                        return
                    default:
                        if let data = response.result.value as? [String: String]{
                            self.message = data["message"]!
                        }
                        completion(false)
                        return
                    }
                }else{
                    self.setMessage(statusMessage: "Something went wrong.")
                    completion(false)
                    return
                }
        }
        }
    
    /*func registerNewUser () {
        let parameters: Parameters = ["username": "artotesti", "password": "siika1", "email": "artosiika@siika.fi"]
        
        Alamofire.request("http://media.mw.metropolia.fi/arsu/users?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywidXNlcm5hbWUiOiJtb2kiLCJlbWFpbCI6Im1vaUBleGFtcGxlLmNvbSIsImlzX2FkbWluIjpudWxsLCJkYXRlIjoiMjAxNi0xMS0xNVQxNjowMToyMy4wMDBaIiwiaWF0IjoxNDc5NzI3OTIxLCJleHAiOjE1MTEyNjM5MjF9.RpcVjLHec2NZ4C4M0yxfGBA3utF0X8l7ehIQe3POLws", method: .post, parameters:parameters, encoding: JSONEncoding.default)
            .responseJSON{response in
                print(response.request)
                if let json = response.result.value as? [String: String] {
                    print(json)
                }else{
                    self.setMessage(statusMessage: "Ei toimi")
                }
        }
    }*/
    
}
