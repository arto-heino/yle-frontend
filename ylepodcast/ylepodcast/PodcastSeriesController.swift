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
    
    var podcasts = [Podcast]()
    var podcast: Podcast?
    var seriesID: String?
    var url: String = ""
    let dataParser = HttpRequesting()
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    var parentVC: AudioController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func initializeFetchedResultsController() {
            let request = NSFetchRequest<Podcast>(entityName: "Podcast")
            let titleSort = NSSortDescriptor(key: "podcastTitle", ascending: true)
            request.sortDescriptors = [titleSort]
            
            request.predicate = NSPredicate(format: "podcastCollectionID == %@", seriesID!)
            print(request)
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func urlDecrypted(url: String) {
        self.url = url
        self.parentVC?.podcast = self.podcast
        self.parentVC?.podcastUrl = self.url
        self.parentVC?.updatePlayerVisuals()
        self.parentVC?.setUpPlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    //MARK: PROPERTIES
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

