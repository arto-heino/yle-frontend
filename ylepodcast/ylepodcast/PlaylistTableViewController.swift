//
//  PlaylistTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class PlaylistTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    var preferences = UserDefaults.standard
    var userPodcast = HttpPosts()
    
    @IBAction func createNewPlaylistAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Luo soittolista", message: "Luo uusi soittolista", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
        }
        
        alert.addAction(UIAlertAction(title: "Peruuta", style: UIAlertActionStyle.default, handler: nil))
        
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
                
                DatabaseController.saveContext()
                self.refresh()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func refresh() {
        // refresh core data
        self.initializeFetchedResultsController()
        // refresh view
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCell(cell: PlaylistTableViewCell, indexPath: IndexPath) {
        
        let selectedObject = fetchedResultsController.object(at: indexPath)
        cell.myPlaylistNameLabel.text = selectedObject.playlistName
        cell.myItemsInPlaylist.text = "\(selectedObject.podcast!.count) podcastia"
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PlaylistTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaylistTableViewCell
        // Set up the cell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "contentInPlaylist") as? PlaylistContentViewController {
            nextViewController.selectedPlaylist = selectedObject
            self.navigationController?.show(nextViewController, sender: nil)
        }
    }
    
    //TODO: Need to ask do you want to remove playlist
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        let addAction = UITableViewRowAction(style: .normal, title: "Poista", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in

            let playlistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaylistController") as! PlaylistTableViewController
            
            let token: String = self.preferences.object(forKey: "userKey") as! String
            let playlistID = String(selectedObject.playlistID)
            let url: String = "http://media.mw.metropolia.fi/arsu/playlists/" + playlistID
            
            self.userPodcast.httpDeleteFromBackend(url: url, token: token){ success in
                if(success){
                    DatabaseController.getContext().delete(selectedObject)
                    DatabaseController.saveContext()
                    self.refresh()
                }else{
                    print("Virhe poistaessa")
                }
                
            }
        })
        
        addAction.backgroundColor = UIColor.red
        return [addAction]
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
