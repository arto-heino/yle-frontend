//
//  PlaylistTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class PlaylistTableViewController: UITableViewController {
    
    var Playlist = CoreDataStack()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class SectionsData {
        var getPlaylist = HttpRequesting()
        let preferences = UserDefaults.standard
        var playlistsUser = [String]()
        
        func getSectionsFromData() -> [Section] {
            var sectionsArray = [Section]()
            let token: String = self.preferences.object(forKey: "userKey") as? String ?? ""
            let id: String = self.preferences.object(forKey: "userID") as? String ?? ""
            let url: String = "http://media.mw.metropolia.fi/arsu/playlists/user/4" + id
            
            getPlaylist.httpGetFromBackend(url: url, token: token) { success in
                for (_, event) in (success.enumerated()) {
                    //self.playlistsUser.append(event["playlist_name"]!)
                    
                    //let playlist = Playlist(context: context)
                    //playlist.playlistName = event["playlist_name"]!
                    //playlist.playlistID = event["id"] as Int64
                    //playlist.playlistUserID = event["user_id"] as Int64
                }
            }

            let myPodcasts = Section(title: "Omat", objects: self.playlistsUser)
            let recommended = Section(title: "Valmiit", objects: ["Yle Puhe", "Aamulypsy"])
            let favorites = Section(title: "Suosikit", objects: ["Suosikki 1", "Suosikki 2", "Suosikki 3"])
            
            
            sectionsArray.append(myPodcasts)
            sectionsArray.append(recommended)
            sectionsArray.append(favorites)
            
            return sectionsArray
        }
    }
    
    struct Section {
        
        var heading : String
        var items : [String]
        
        init(title: String, objects : [String]) {
            
            heading = title
            items = objects
        }
    }
    
    
    var sections: [Section] = SectionsData().getSectionsFromData()
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].heading
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PlaylistTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaylistTableViewCell
        
        cell.myPlaylistNameLabel.text = sections[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    
    
    // MARK: - Table view data source
    
    
        /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
