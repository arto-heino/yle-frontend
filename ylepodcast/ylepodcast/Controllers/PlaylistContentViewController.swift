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
    
    // MARK: VARIABLES
    
    let dataParser = HttpRequesting()
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    
    var selectedPlaylist = Playlist(context: DatabaseController.getContext())

    // MARK: LABELS
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var playlistNameInListingLabel: UILabel!
    
    // MARK: INITIALIZERS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistNameInListingLabel.text = selectedPlaylist.playlistName!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: HELPERS
    
    // FIXME: Need better solution?
    func configureCell(cell: ItemInPlaylistTableViewCell, indexPath: IndexPath) {
        let podcasts = selectedPlaylist.podcast?.allObjects
        let podcast = podcasts as? [Podcast]
        
        var i = 0
        for object in podcast!{
            cell.collectionInPlaylistLabel.text = object.podcastTitle ?? "Ei otsikkoa"
            cell.durationInPlaylistLabel.text = dataParser.secondsToTimeString(seconds: object.podcastDuration)
            
            if indexPath.row == i {
                break
            }
            i = i + 1
        }
    
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
    
}
