//
//  PodcastCategoriedTableViewController.swift
//  ylepodcast
//
//  Created by Arto Heino on 13/12/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class PodcastCategoriedTableViewController: UITableViewController, Playable, NSFetchedResultsControllerDelegate, UrlDecryptObserver {
    
    // MARK: VARIABLES
    
    var category: String = ""
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    let dataParser = HttpRequesting()
    var url: String = ""
    var podcast: Podcast?
    var tabController: TabBarController?
    var name: String = ""
    
    // MARK: INITIALIZER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabController = self.tabBarController as! TabBarController?
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView!.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView!.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)))
        initializeFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabController?.showPlayer(currentView: self)
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Podcast>(entityName: "Podcast")
        let titleSort = NSSortDescriptor(key: "podcastTitle", ascending: true)
        request.sortDescriptors = [titleSort]
        
        // Filter podcast by using category, which is sended by Category
        let attribute = "category.categoryTag"
        let commentPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", attribute, category)
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
    
    // MARK: HELPERS
    
    func urlDecrypted(url: String) {
        self.url = url
        self.tabController?.hidePlayer()
        toPlayerView()
    }
    
    // Set up the segue to play the podcast send (podcast, podcastUrl)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "AudioSegue6" {
            let destination = segue.destination as! AudioController
            destination.podcast = podcast
            destination.podcastUrl = url
        }
    }
    
    func toPlayerView() {
        performSegue(withIdentifier: "AudioSegue6", sender: Any?.self)
    }
    
    func configureCell(cell: PodcastTableViewCell, indexPath: IndexPath) {
        let selectedObject = fetchedResultsController.object(at: indexPath)
        
        cell.collectionLabel.text = selectedObject.podcastTitle
        cell.descriptionLabel.text = selectedObject.podcastDescription
        cell.durationLabel.text = dataParser.secondsToTimeString(seconds: selectedObject.podcastDuration)
        let podcastImageData = selectedObject.podcastImage
        if podcastImageData != nil {
            let image = UIImage(data: podcastImageData as! Data)
            cell.podcastImageView.image = image
        }
    }
    
    // MARK: TABLEVIEW
    
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
