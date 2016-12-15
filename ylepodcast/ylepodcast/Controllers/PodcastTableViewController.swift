//
//  PodcastTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 31/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class PodcastTableViewController: UITableViewController, UrlDecryptObserver, Playable, NSFetchedResultsControllerDelegate {
    
    // MARK: VARIABLES
    var podcasts = [Podcast]()
    var tabController: TabBarController?
    var podcast: Podcast?
    var url: String = ""
    let dataParser = HttpRequesting()
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    var sortStyle: String = "podcastTitle"
    
    // MARK: INITIALIZER
    override func viewDidLoad() {
        super.viewDidLoad()
        tabController = self.tabBarController as! TabBarController?
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView!.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView!.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)))
        initializeFetchedResultsController(sortStyle: sortStyle)
    }
    
    func initializeFetchedResultsController(sortStyle: String) {
        let request = NSFetchRequest<Podcast>(entityName: "Podcast")
        let titleSort = NSSortDescriptor(key: sortStyle, ascending: true)
        request.sortDescriptors = [titleSort]
        
        let moc = DatabaseController.getContext()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc,sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            controllerWillChangeContent(fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>)
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabController?.showPlayer(currentView: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: HELPERS
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    func urlDecrypted(url: String) {
        self.url = url
        self.tabController?.hidePlayer()
        toPlayerView()
    }
    
    func toPlayerView() {
        performSegue(withIdentifier: "AudioSegue1", sender: Any?.self)
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
    
    // Will refresh the view if new podcasts is parsed or old deleted
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
    
    // Set up the segue to play the podcast send (podcast, podcastUrl)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "AudioSegue1" {
            let destination = segue.destination as! AudioController
            destination.podcast = podcast
            destination.podcastUrl = url
        }
    }
    
    // MARK: ACTIONS

    @IBAction func sortPodcast(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "SUODATA", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Otsikko", style: .default , handler:{ (UIAlertAction)in
            self.sortStyle = "podcastTitle"
            self.initializeFetchedResultsController(sortStyle: self.sortStyle)
        }))
        
        alert.addAction(UIAlertAction(title: "Päivämäärä", style: .default , handler:{ (UIAlertAction)in
            //self.sortStyle = "podcastDate"
            //self.initializeFetchedResultsController(sortStyle: self.sortStyle)
        }))
        
        alert.addAction(UIAlertAction(title: "Kesto", style: .default , handler:{ (UIAlertAction)in
            self.sortStyle = "podcastDuration"
            self.initializeFetchedResultsController(sortStyle: self.sortStyle)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Peruuta", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
            
            
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    // MARK: TABLEVIEW
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PodcastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PodcastTableViewCell

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
        
        // Decrypt the selected podcast url
        dataParser.getAndDecryptUrl(podcast: selectedObject, urlDecryptObserver: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
