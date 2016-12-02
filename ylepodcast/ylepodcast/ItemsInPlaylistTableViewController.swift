//
//  ItemsInPlaylistTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 01/12/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class ItemsInPlaylistTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var playlistNameInListingLabel: UILabel!
    
    
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func initializeFetchedResultsController() {
            let request = NSFetchRequest<Playlist>(entityName: "Playlist")
            let nameSort = NSSortDescriptor(key: "playlistName", ascending: true)
            request.sortDescriptors = [nameSort]
            
            let moc = DatabaseController.getContext()
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request as! NSFetchRequest<Podcast>, managedObjectContext: moc,sectionNameKeyPath: nil, cacheName: nil)
            
            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
                
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }


    }
        initializeFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    // MARK: - Table view data source

    func configureCell(cell: ItemInPlaylistTableViewCell, indexPath: IndexPath) {
        guard let selectedObject = (fetchedResultsController.object(at: indexPath)) as? Podcast else { fatalError("Unexpected Object in FetchedResultsController") }
        // Populate cell from the NSManagedObject instance
        cell.collectionInPlaylistLabel.text = selectedObject.podcastCollection
        //count podcasts in playlist
        //cell.itemsInPlaylistLabel.text =
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemInPlaylistCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemInPlaylistTableViewCell
        // Set up the cell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
            configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)! as! ItemInPlaylistTableViewCell, indexPath: indexPath! as IndexPath)
        case .move:
            tableView.moveRow(at: indexPath! as IndexPath, to: newIndexPath! as IndexPath)
        }
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController<Playlist>) {
        tableView.endUpdates()
    }
   /* override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Podcast else { fatalError("Unexpected Object in FetchedResultsController") }
        let addAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            let usersPlaylistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemsInPlaylistController") as! ItemsInPlaylistTableViewController
            
            usersPlaylistController.selectedPodcast = [selectedObject]
            
            
            self.show(usersPlaylistController, sender: nil)
        })
        
        addAction.backgroundColor = UIColor.red
        return [addAction]
    }*/

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
