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
    
    func getPlaylists(){
        let token: String = preferences.object(forKey: "userKey") as? String ?? ""
        let id: String = preferences.object(forKey: "userID") as? String ?? ""
        let url: String = "http://media.mw.metropolia.fi/arsu/playlists/user/" + id
        
        do{
            let context = DatabaseController.getContext()
            let result = try context.fetch(Playlist.fetchRequest())
            let playlist = result as! [Playlist]
            
            if(playlist.count == 0){
                userRequests.httpGetFromBackend(url: url, token: token) { success in
                    for (_, event) in (success.enumerated()) {
                        let context = DatabaseController.getContext()
                        let playlist = Playlist(context: context)
                        
                        playlist.playlistID = event["id"] as! Int64
                        playlist.playlistName = event["playlist_name"] as! String?
                        playlist.playlistUserID = event["user_id"] as! Int64
                        playlist.playlistTypeName = "Omat soittolistat"
                        DatabaseController.saveContext()
                    }
                    
                }
            }else{
                print("do nothing")
            }
        }catch{
            print("model is lost")
        }

    }
    
    func logOut(){
        
        do{
            let context = DatabaseController.getContext()
            let result = try context.fetch(Playlist.fetchRequest())
            let playlist = result as! [Playlist]
            
            if(playlist.count != 0){
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                    DatabaseController.saveContext()
                }
                catch {
                }
            }else{
                print("do nothing")
            }
        }catch{
            print("model is lost")
        }
        
    }

}
