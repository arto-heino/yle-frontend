//
//  SearchTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class SearchTableViewController: UITableViewController , UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: VARIABLES
    
    let searchController = UISearchController(searchResultsController: nil)
    let dataParser = HttpRequesting()

    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    let moc = DatabaseController.getContext()

    // MARK: INITIALIZERS
    
    override func viewDidLoad() {

        super.viewDidLoad()
        getData(scope: 0, searchString: nil)
        
        //Create a search bar
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Hae..."
        searchController.searchBar.scopeButtonTitles = ["Jakso","Sarja","Kuvaus","Avainsanat"]
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: FUNCTIONS
    // FIXME: Should not fetch anything if user don´t search nothing
    // Do a fetch result by using a user typed search string and selected search scope (Jakso, Sarja, Kuvaus, Avainsanat), (scope, searchString) Return Podcasts
    func getData(scope: Int, searchString: String?){
        
        let request = NSFetchRequest<Podcast>(entityName: "Podcast")
        var attribute = ""

        if(searchString != nil){
            switch(scope){
            case 0:
                attribute = "podcastTitle"
            case 1:
                attribute = "podcastCollection"
            case 2:
                attribute = "podcastDescription"
            case 3:
                attribute = "podcastTags"
            default:
                attribute = "podcastTitle"
                break
            }
            
            let sorter = NSSortDescriptor(key: attribute, ascending: true)
            request.sortDescriptors = [sorter]
            let commentPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", attribute, searchString!)
            request.predicate = commentPredicate
        }else{
            let sorter = NSSortDescriptor(key: "podcastCollection", ascending: true)
            request.sortDescriptors = [sorter]
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            controllerWillChangeContent(fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>)
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    // MARK: HELPERS
    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String) {
        
        filterContent(forSearchText: searchText)
    }
    
    //filters through keyword and scope
    func filterContent(forSearchText searchText: String) {
        
        let scope = searchController.searchBar.selectedScopeButtonIndex
        getData(scope: scope, searchString: searchText)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: TABLEVIEW

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectedObject = fetchedResultsController?.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemTableViewCell", for: indexPath ) as! SearchItemTableViewCell

        let podcast = selectedObject
        
        cell.collectionLabel.text = podcast?.podcastTitle
        cell.descriptionLabel.text = podcast?.podcastDescription
        cell.durationLabel.text = dataParser.secondsToTimeString(seconds: (podcast?.podcastDuration)!)
        
        let podcastImageData = podcast?.podcastImage
        if podcastImageData != nil {
            let image = UIImage(data: podcastImageData as! Data)
            
            cell.podcastImage.image = image
        }

        return cell
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

}
