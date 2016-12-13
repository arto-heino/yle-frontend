//
//  UsersPlaylistTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 29/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

//This is the view that is shown when user is swipe-adding a podcast to a new or existing podcast list.

class UsersPlaylistTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let context = DatabaseController.getContext()
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    
    var selectedPodcast: Podcast?
    var userPodcast = HttpPosts()
    var preferences = UserDefaults.standard
    
    
    @IBAction func cancelAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createOwnPlaylist(_ sender: Any) {
    
        
        let alert = UIAlertController(title: "Luo soittolista", message: "Luo uusi soittolista", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Peruuta", style: UIAlertActionStyle.default, handler: nil))
        
        // Add playlist to coredata and backend
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let context = DatabaseController.getContext()
            let playlist = Playlist(context: context)
            
            let parameters: Parameters = ["playlist_name": textField!.text!]
            let token: String = self.preferences.object(forKey: "userKey") as! String
            let url: String = "http://media.mw.metropolia.fi/arsu/playlists/"
            
            self.userPodcast.httpPostToBackend(url: url, token: token, parameters: parameters){ success in
                    playlist.playlistName = textField!.text
                    playlist.playlistID = success["id"] as! Int64
                    playlist.playlistUserID = self.preferences.object(forKey: "userID") as! Int64

                    playlist.addToPodcast(self.selectedPodcast!)
                    
                    DatabaseController.saveContext()
            }
  
            self.performSegue(withIdentifier: "createAPlaylist", sender: self)

        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Playlist>(entityName: "Playlist")
        let nameSort = NSSortDescriptor(key: "playlistName", ascending: true)
        request.sortDescriptors = [nameSort]
        
        let moc = DatabaseController.getContext()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc,sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func configureCell(cell: UsersPlaylistTableViewCell, indexPath: IndexPath) {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        cell.ownPlaylistLabel.text = selectedObject.playlistName
        cell.itemsInPlaylistLabel.text = "\(selectedObject.podcast!.count) podcastia"
        print(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        
        let token: String = preferences.object(forKey: "userKey") as? String ?? ""
        let url: String = "http://media.mw.metropolia.fi/arsu/playlists/" + String(selectedObject.playlistID)
        let parameters: Parameters = ["podcast_id": self.selectedPodcast!.podcastID]
        //FIXME: Need to check double podcasts
        userPodcast.httpPutToBackend(url: url, token: token, parameters: parameters) { success in
            if(success){
                selectedObject.addToPodcast(self.selectedPodcast!)
                DatabaseController.saveContext()
                let message: String = self.selectedPodcast!.podcastTitle! + ", lisätty listaan."
                let alert = UIAlertController(title: "Lisätty soittolistaan", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    print(alert ?? "painoit")
                }))
                self.refresh()
                self.present(alert, animated: true, completion: nil)
            }else{
                let message: String = self.selectedPodcast!.podcastTitle! + ", lisääminen listaan epäonnistui."
                let alert = UIAlertController(title: "Virhe", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    print(alert ?? "painoit")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UsersPlaylistCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UsersPlaylistTableViewCell
        // Set up the cell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections?[section]
        return sectionInfo!.numberOfObjects
    }
    
    func refresh() {
        // refresh core data
        self.initializeFetchedResultsController()
        // refresh view
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

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
