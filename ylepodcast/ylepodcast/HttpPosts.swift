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
                            let preferences = UserDefaults.standard
                            preferences.set(data["token"], forKey: "userKey")
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
    
    func httpRegister (username:String, password: String, email: String, completion:@escaping (Bool) -> Void) {
        let parameters: Parameters = ["username": username, "password": password, "email": email]
        
        let headers: HTTPHeaders = [
            "x-access-token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywidXNlcm5hbWUiOiJtb2kiLCJlbWFpbCI6Im1vaUBleGFtcGxlLmNvbSIsImlzX2FkbWluIjpudWxsLCJkYXRlIjoiMjAxNi0xMS0xNVQxNjowMToyMy4wMDBaIiwiaWF0IjoxNDc5ODkzNTAxLCJleHAiOjE1MTE0Mjk1MDF9.7J3SHaIBZl5Q5kcKTa_7S8spYADzW9gxzB260OTQAWI"
        ]
        
        Alamofire.request("http://media.mw.metropolia.fi/arsu/users", method: .post, parameters:parameters, encoding: JSONEncoding.default, headers:headers)
            .responseJSON{response in
                print(response)
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 201:
                        if let data = response.result.value as? [String: String]{
                            self.message = data["message"]!
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
    
    func httpPostToBackend (url:String!, token: String!, parameters: Parameters, completion:@escaping ([String:Any]) -> Void) {
        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        
        Alamofire.request(url, method: .post, parameters:parameters, encoding: JSONEncoding.default, headers:headers)
            .responseJSON{response in
                print(response)
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 201:
                        if let data = response.result.value as? [String: Any]{
                        completion(data)
                        return
                        }
                    default:
                        if let data = response.result.value as? [String: Any]{
                        completion(data)
                        return
                        }
                    }
                }else{
                    self.setMessage(statusMessage: "Something went wrong.")
                    return
                }
        }
    }
    
    func httpDeleteFromBackend (url:String!, token: String!, completion:@escaping (Bool) -> Void) {

        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
    
        Alamofire.request(url, method: .delete, encoding: JSONEncoding.default, headers:headers)
            .responseJSON{response in
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:

                            completion(true)
                            return
                    default:
                            completion(false)
                            return
                    }
                }else{
                    self.setMessage(statusMessage: "Something went wrong.")
                    return
                }
        }
    }
    
    func httpPutToBackend (url:String!, token: String!, parameters: Parameters!, completion:@escaping (Bool) -> Void) {
        
        let headers: HTTPHeaders = [
            "x-access-token": token
        ]
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers:headers)
            .responseJSON{response in
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 201:
                        completion(true)
                        return
                    default:
                        completion(false)
                        return
                    }
                }else{
                    self.setMessage(statusMessage: "Something went wrong.")
                    return
                }
        }
    }
    
}
