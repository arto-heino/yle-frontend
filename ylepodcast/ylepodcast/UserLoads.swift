//
//  UserLoads.swift
//  ylepodcast
//
//  Created by Arto Heino on 29/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation

class UserLoads{
    
    let userRequests = HttpRequesting()
    var preferences = UserDefaults.standard
    let token: String
    
    init() {
        token = preferences.object(forKey: "userKey") as? String ?? ""
    }
    
    func getPlaylists(){

        let id: String = preferences.object(forKey: "userID") as? String ?? ""
        let url: String = "http://media.mw.metropolia.fi/arsu/playlists/user/" + id
        
        do{
            let context = DatabaseController.getContext()
            let result = try context.fetch(Playlist.fetchRequest())
            let playlist = result as! [Playlist]
            
            if(playlist.count > 0){
                userRequests.httpGetFromBackend(url: url, token: self.token) { success in
                    for (_, event) in (success.enumerated()) {
                        let context = DatabaseController.getContext()
                        let playlist = Playlist(context: context)

                        playlist.playlistID = event["id"] as! Int64
                        playlist.playlistName = event["playlist_name"] as! String?
                        playlist.playlistUserID = event["user_id"] as! Int64
                        playlist.playlistTypeName = "Omat soittolistat"
                        DatabaseController.saveContext()
                    }
                    self.getPodcastsToPlaylist()
                }
            }else{
                print("do nothing")
            }
        }catch{
            print("model is lost")
        }

    }
    
    func getPodcastsToPlaylist(){
        do{
            let context = DatabaseController.getContext()
            let result = try context.fetch(Playlist.fetchRequest())
            let playlist = result as! [Playlist]
            
            for (_,playlist) in playlist.enumerated(){
                let playlistID = String(playlist.playlistID)
                let url2: String = "http://media.mw.metropolia.fi/arsu/playlists/" + playlistID

                userRequests.httpGetFromBackend(url: url2, token: self.token) { success in
                    print(success)
                    for (_, event) in (success.enumerated()) {
                        let c_id = event["content"] as? [[String:String]]
                        for(_,content) in (c_id?.enumerated())! {
                            print(content["podcast_id"])
                        }
                    }
                }
            
            }
        }catch{
            
        }
    }

}
