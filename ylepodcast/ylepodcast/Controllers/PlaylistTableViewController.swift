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
    
    // MARK: VARIABLES
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    var preferences = UserDefaults.standard
    var userPodcast = HttpPosts()
    
    // MARK: ACTIONS
    // Add new playlist to backend and CoreData
    @IBAction func createNewPlaylistAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Luo soittolista", message: "Luo uusi soittolista", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
        }
        
        alert.addAction(UIAlertAction(title: "Peruuta", style: UIAlertActionStyle.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
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
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: INITIALIZER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView!.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView!.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)))
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Playlist>(entityName: "Playlist")
        let nameSort = NSSortDescriptor(key: "playlistName", ascending: true)
        request.sortDescriptors = [nameSort]
        
        // FIXME: Bug in playlist names
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
    
    // MARK: HELPERS
    
    func configureCell(cell: PlaylistTableViewCell, indexPath: IndexPath) {
        
        let selectedObject = fetchedResultsController.object(at: indexPath)
        cell.myPlaylistNameLabel.text = selectedObject.playlistName
        cell.myItemsInPlaylist.text = "\(selectedObject.podcast!.count) podcastia"
    
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            return
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            return
        }
    }
    
    // MARK: TABLEVIEW
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PlaylistTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaylistTableViewCell

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
    
    // FIXME: Need to ask do you want to remove playlist
    // Add action to delete playlist by swiping
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        let addAction = UITableViewRowAction(style: .normal, title: "Poista", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let token: String = self.preferences.object(forKey: "userKey") as! String
            let playlistID = String(selectedObject.playlistID)
            let url: String = "http://media.mw.metropolia.fi/arsu/playlists/" + playlistID
            
            self.userPodcast.httpDeleteFromBackend(url: url, token: token){ success in
                if(success){
                    DatabaseController.getContext().delete(selectedObject)
                    DatabaseController.saveContext()
                }else{
                    // Need to give error to user too?
                    print("Error when deleting playlist")
                }
                
            }
        })
        
        addAction.backgroundColor = UIColor.red
        return [addAction]
    }
    
}
