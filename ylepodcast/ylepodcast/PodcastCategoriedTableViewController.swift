//
//  PodcastCategoriedTableViewController.swift
//  ylepodcast
//
//  Created by Arto Heino on 13/12/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class PodcastCategoriedTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UrlDecryptObserver {
    
    var category: String = ""
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    let dataParser = HttpRequesting()
    var url: String = ""
    var podcast: Podcast?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func initializeFetchedResultsController() {
            let request = NSFetchRequest<Podcast>(entityName: "Podcast")
            let titleSort = NSSortDescriptor(key: "podcastTitle", ascending: true)
            request.sortDescriptors = [titleSort]
            
            let commentPredicate = NSPredicate(format: "%K == %@", "podcastCategory", category)
            request.predicate = commentPredicate
            
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
    }
    
    func urlDecrypted(url: String) {
        self.url = url
        performSegue(withIdentifier: "AudioSegue1", sender: Any?.self)
    }
    
    func configureCell(cell: PodcastTableViewCell, indexPath: IndexPath) {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        
        cell.collectionLabel.text = selectedObject.podcastCollection
        cell.descriptionLabel.text = selectedObject.podcastDescription
        cell.durationLabel.text = dataParser.secondsToTimeString(seconds: selectedObject.podcastDuration)
        let podcastImageData = selectedObject.podcastImage
        if podcastImageData != nil {
            let image = UIImage(data: podcastImageData as! Data)
            cell.podcastImageView.image = image
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PodcastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PodcastTableViewCell
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedObject = fetchedResultsController.object(at: indexPath)
        podcast = selectedObject
        dataParser.getAndDecryptUrl(podcast: selectedObject, urlDecryptObserver: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "AudioSegue1" {
            let destination = segue.destination as! AudioController
            destination.podcast = podcast
            destination.podcastUrl = url
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        let addAction = UITableViewRowAction(style: .normal, title: "Lisää", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            let usersPlaylistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersPlaylist") as! UsersPlaylistTableViewController
            
            usersPlaylistController.selectedPodcast = selectedObject
            
            
            self.show(usersPlaylistController, sender: nil)
        })
        
        addAction.backgroundColor = UIColor.init(red: 20/255.0, green: 188/255.0, blue: 210/255.0, alpha: 0.5)
        return [addAction]
    }
    
}
