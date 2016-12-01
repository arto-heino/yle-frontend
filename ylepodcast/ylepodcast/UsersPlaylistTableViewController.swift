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

class UsersPlaylistTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    let context = DatabaseController.getContext()
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    
    var selectedPodcast = Podcast()
    var userPodcast = HttpPosts()
    var preferences = UserDefaults.standard
    
    
    @IBAction func createOwnPlaylist(_ sender: Any) {
        
        let alert = UIAlertController(title: "Luo soittolista", message: "Luo uusi soittolista", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Peruuta", style: UIAlertActionStyle.default, handler: nil))
        
        //FIXME: Add adding playlist name to coredata
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
                
                    //playlist.addToPodcast(self.selectedPodcast)
                    
                    DatabaseController.saveContext()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        initializeFetchedResultsController()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func configureCell(cell: UsersPlaylistTableViewCell, indexPath: IndexPath) {
        guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Playlist else { fatalError("Unexpected Object in FetchedResultsController") }
        // Populate cell from the NSManagedObject instance
        cell.ownPlaylistLabel.text = selectedObject.playlistName
        //count podcasts in playlist
        //cell.itemsInPlaylistLabel.text =
        
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
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController<Playlist>) {
        tableView.beginUpdates()
    }
    
    private func controller(controller: NSFetchedResultsController<Playlist>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    private func controller(controller: NSFetchedResultsController<Playlist>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)! as! UsersPlaylistTableViewCell, indexPath: indexPath! as IndexPath)
        case .move:
            tableView.moveRow(at: indexPath! as IndexPath, to: newIndexPath! as IndexPath)
        }
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController<Playlist>) {
        tableView.reloadData()
        tableView.endUpdates()
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
