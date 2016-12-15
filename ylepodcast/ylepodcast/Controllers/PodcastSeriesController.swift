//
//  PodcastSeriesController.swift
//  ylepodcast
//
//  Created by Milos Berka on 13.12.2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class PodcastSeriesController: UITableViewController, UrlDecryptObserver, NSFetchedResultsControllerDelegate {
    
    // MARK: VARIABLES
    var podcasts = [Podcast]()
    var podcast: Podcast?
    var seriesID: String?
    var url: String = ""
    let dataParser = HttpRequesting()
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    var parentVC: AudioController?
    
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
        let request = NSFetchRequest<Podcast>(entityName: "Podcast")
        let titleSort = NSSortDescriptor(key: "podcastTitle", ascending: true)
        request.sortDescriptors = [titleSort]
        
        // Filter the podcasts by given podcastCollectionID
        request.predicate = NSPredicate(format: "podcastCollectionID == %@", seriesID!)
        
        let moc = DatabaseController.getContext()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc,sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: HELPERS
    
    func urlDecrypted(url: String) {
        self.url = url
        self.parentVC?.podcast = self.podcast
        self.parentVC?.podcastUrl = self.url
        self.parentVC?.updatePlayerVisuals()
        self.parentVC?.setUpPlayer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "AudioSegue1" {
            let destination = segue.destination as! AudioController
            destination.podcast = podcast
            destination.podcastUrl = url
            
        }
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
        self.podcast = selectedObject
        if self.parentVC?.podcast != self.podcast {
            dataParser.getAndDecryptUrl(podcast: selectedObject, urlDecryptObserver: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
    }
    
    // Add, add podcast to playlist action to tableview
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
