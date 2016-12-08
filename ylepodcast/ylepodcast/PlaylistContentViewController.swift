//
//  PlaylistContentViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 02/12/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class PlaylistContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    let dataParser = HttpRequesting()
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    
    var selectedPlaylist = Playlist(context: DatabaseController.getContext())

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var playlistNameInListingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistNameInListingLabel.text = selectedPlaylist.playlistName!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    // TODO: Need better solution?
    func configureCell(cell: ItemInPlaylistTableViewCell, indexPath: IndexPath) {
        let podcasts = selectedPlaylist.podcast?.allObjects
        let podcast = podcasts as? [Podcast]
        
        var i = 0
        for object in podcast!{
            cell.collectionInPlaylistLabel.text = object.podcastCollection ?? "Ei otsikkoa"
            cell.durationInPlaylistLabel.text = dataParser.secondsToTimeString(seconds: object.podcastDuration)
            
            if indexPath.row == i {
                break
            }
            i = i + 1
        }
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemInPlaylistCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemInPlaylistTableViewCell
        // Set up the cell
        
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int = (selectedPlaylist.podcast?.allObjects.count)!
        return count
    }
    
    /*private func controllerWillChangeContent(controller: NSFetchedResultsController<Playlist>) {
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
