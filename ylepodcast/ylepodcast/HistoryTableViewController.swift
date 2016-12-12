//
//  HistoryTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UrlDecryptObserver {
    
    var fetchedResultsController: NSFetchedResultsController<History>!
    var preferences = UserDefaults.standard
    let dataParser = HttpRequesting()
    var url: String = ""
    var name: String = ""
    var podcast: Podcast?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest<History>(entityName: "History")
        let titleSort = NSSortDescriptor(key: "historyID", ascending: true)
        request.sortDescriptors = [titleSort]
        
        let moc = DatabaseController.getContext()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc,sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }

    func urlDecrypted(url: String) {
        
        self.url = url
        performSegue(withIdentifier: "AudioSegue1", sender: Any?.self)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    func configureCell(cell: HistoryTableViewCell, indexPath: IndexPath) {
        
        let selectedObject = fetchedResultsController.object(at: indexPath)
        let podcastObj = selectedObject.podcast?.allObjects
        let podcasts = podcastObj as? [Podcast]
        
        var i = 0
        for object in podcasts!{
            cell.collectionLabel.text = object.podcastCollection
            cell.descriptionLabel.text = object.podcastDescription
            cell.durationLabel.text = dataParser.secondsToTimeString(seconds: object.podcastDuration)
            let podcastImageData = object.podcastImage
            if podcastImageData != nil {
                let image = UIImage(data: podcastImageData as! Data)
                cell.podcastImageView.image = image
            }
            
            if indexPath.row == i {
                break
            }
            i = i + 1
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "HistoryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryTableViewCell
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
        
        let podcastObj = selectedObject.podcast?.allObjects
        let podcasts = podcastObj as? [Podcast]
        
        var i = 0
        for object in podcasts!{
                name = object.podcastCollection!
                podcast = object
                dataParser.getAndDecryptUrl(podcast: object, urlDecryptObserver: self)
            if indexPath.row == i {
                break
            }
            i = i + 1
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "AudioSegue1" {
            let destination = segue.destination as! AudioController
            destination.podcastUrl = url
            destination.podcastName = name
            destination.podcast = podcast
        }
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController<History>) {
        
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<History>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
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
    
    private func controller(controller: NSFetchedResultsController<History>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)! as! HistoryTableViewCell, indexPath: indexPath! as IndexPath)
        case .move:
            tableView.moveRow(at: indexPath! as IndexPath, to: newIndexPath! as IndexPath)
        }
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController<History>) {
        
        tableView.endUpdates()
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
