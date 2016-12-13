//
//  UserLoads.swift
//  ylepodcast
//
//  Created by Arto Heino on 29/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation
import CoreData

class UserLoads{
    
    let userRequests = HttpRequesting()
    var preferences = UserDefaults.standard
    let token: String
    
    init() {
        token = preferences.object(forKey: "userKey") as? String ?? ""
    }
    
    // MARK: - PLAYLISTS

    func getPlaylists(){
        
        let token = preferences.object(forKey: "userKey") as? String ?? ""
        let id: String = preferences.object(forKey: "userID") as? String ?? ""
        let url: String = "http://media.mw.metropolia.fi/arsu/playlists/user/" + id
        
        do{
            let context = DatabaseController.getContext()
            let result = try context.fetch(Playlist.fetchRequest())
            let playlist = result as! [Playlist]
            
            // FIXME: Need to apply better solution to find if there is new playlists in backend
            if(playlist.count == 0){
                userRequests.httpGetFromBackend(url: url, token: token) { success in
                    let object = success as! [Any]
                    for (_, event) in (object.enumerated()) {
                        let context = DatabaseController.getContext()
                        let playlist = Playlist(context: context)
                        var playlist_item = event as! [String:Any]
                        playlist.playlistID = playlist_item["id"] as! Int64
                        playlist.playlistName = playlist_item["playlist_name"] as! String?
                        playlist.playlistUserID = playlist_item["user_id"] as! Int64
                        
                        DatabaseController.saveContext()
                    }
                    self.getPodcastsToPlaylist()
                }
            }else{
                // Need to check new playlists
            }
        }catch{
            print("Error in fetching playlists!")
        }

    }
    
    func getPodcastsToPlaylist(){
        
        do{
            let token = preferences.object(forKey: "userKey") as? String ?? ""
            let context = DatabaseController.getContext()
            
            let result_playlist = try context.fetch(Playlist.fetchRequest())
            let result_podcast = try context.fetch(Podcast.fetchRequest())
            
            let podcast = result_podcast as! [Podcast]
            let playlist = result_playlist as! [Playlist]
            
            for (_,playlist) in playlist.enumerated(){
                let playlistID = String(playlist.playlistID)
                let url2: String = "http://media.mw.metropolia.fi/arsu/playlists/" + playlistID
                
                userRequests.httpGetFromBackend(url: url2, token: token) { success in
                    let object = success as! [String: AnyObject]
                    if let details = object["content"] as? [Any]{
                        for object in details{
                            let content = object as! [String:Any]
                            let podcast_id = content["podcast_id"] as! Int64
                            for (_,podcast) in podcast.enumerated(){
                                if(podcast.podcastID == podcast_id){
                                    podcast.addToPlaylists(playlist)
                                    DatabaseController.saveContext()
                                }
                            }
                        }
                    }
                }
            
            }
        }catch{
            print("Error in fetching podcasts to playlist")
        }
    }
    
    // MARK: - HISTORY

    func getHistory(){
        
        let token = preferences.object(forKey: "userKey") as? String ?? ""
        let url: String = "http://media.mw.metropolia.fi/arsu/history"
        
        do{
            let context = DatabaseController.getContext()
            let result = try context.fetch(History.fetchRequest())
            let result_podcast = try context.fetch(Podcast.fetchRequest())

            let history = result as! [History]
            let podcast = result_podcast as! [Podcast]
            
            // FIXME: Need to apply better solution to find if there is new history in backend
            if(history.count == 0){
                userRequests.httpGetFromBackend(url: url, token: token) { success in
                    let object = success as! [Any]
                    for (_, event) in (object.enumerated()) {
                        let context = DatabaseController.getContext()
                        let history = History(context: context)
                        var history_item = event as! [String:Any]
                        
                        history.historyID = history_item["id"] as! Int64
                        let podcast_id = history_item["podcast_id"] as! Int64
                        history.historyUserID = history_item["user_id"] as! Int64
                        
                        for (_,podcast) in podcast.enumerated(){
                            if(podcast.podcastID == podcast_id){
                                history.addToPodcast(podcast)
                            }
                        }
                        
                        DatabaseController.saveContext()
                    }
                }
            }else{
                // Need to check new playlists
            }
        }catch{
            print("Error in fetching history")
        }
        
    }
    
    // MARK: - LOGOUT
    // Delete all user-related entitys
    func logOut(){
        
            self.preferences.removeObject(forKey: "userKey")
            self.preferences.removeObject(forKey: "userName")
            self.preferences.removeObject(forKey: "userID")
        
            DatabaseController.clear(table: "Playlist")
            DatabaseController.clear(table: "History")
    }

}
