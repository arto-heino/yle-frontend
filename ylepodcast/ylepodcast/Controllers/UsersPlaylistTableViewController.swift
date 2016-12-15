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
    
    // MARK: VARIABLES
    
    let context = DatabaseController.getContext()
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    
    var selectedPodcast: Podcast?
    var userPodcast = HttpPosts()
    var preferences = UserDefaults.standard
    
    // MARK: ACTIONS
    
    @IBAction func cancelAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // FIXME: Need to add error checking
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
    
    // MARK: INITIALIZER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView!.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView!.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Playlist>(entityName: "Playlist")
        let nameSort = NSSortDescriptor(key: "playlistName", ascending: true)
        request.sortDescriptors = [nameSort]
        
        // FIXME: Why there are empty playlists?
        request.predicate = NSPredicate(format: "playlistName != nil")
        
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

    // MARK: TABLEVIEW
    
    func configureCell(cell: UsersPlaylistTableViewCell, indexPath: IndexPath) {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        cell.ownPlaylistLabel.text = selectedObject.playlistName
        // FIXME: Does not refresh podcast count correct
        cell.itemsInPlaylistLabel.text = "\(selectedObject.podcast!.count) podcastia"
    }
    
    // FIXME: Need to check error message and does this work
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
                    // FIXME: Need to be smooth and switch to sended view
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") as! PodcastTableViewController
                    
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }))
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            return
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(cell: tableView.cellForRow(at: indexPath!) as! UsersPlaylistTableViewCell, indexPath: indexPath!)
        default:
            return
        }
    }
    
}
