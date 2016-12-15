//
//  SearchTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData

class SearchTableViewController: UITableViewController, Playable, UrlDecryptObserver, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: VARIABLES
    
    let searchController = UISearchController(searchResultsController: nil)
    let dataParser = HttpRequesting()
    var tabController: TabBarController?
    var podcast: Podcast?
    var url: String = ""
    
    var fetchedResultsController: NSFetchedResultsController<Podcast>!
    let moc = DatabaseController.getContext()
    
    // MARK: INITIALIZERS
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tabController = self.tabBarController as! TabBarController?
        //getData(scope: 0, searchString: nil)
        
        //Create a search bar
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Hae..."
        searchController.searchBar.scopeButtonTitles = ["Kaikki","Avainsanat"]
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabController?.showPlayer(currentView: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: FUNCTIONS
    // Do a fetch result by using a user typed search string and selected search scope (Kaikki, Avainsanat), (scope, searchString) Return Podcasts
    func getData(scope: Int, searchString: String?){
        
        let request = NSFetchRequest<Podcast>(entityName: "Podcast")
        var attribute = ""
        let sorter = "podcastTitle"
        
        switch(scope){
        case 0:
            let predicate1 = NSPredicate(format: "podcastTitle CONTAINS[cd] %@", searchString!)
            let predicate2 = NSPredicate(format: "podcastCollection CONTAINS[cd] %@", searchString!)
            let predicate3 = NSPredicate(format: "podcastDescription CONTAINS[cd] %@", searchString!)
            let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2,predicate3])
            request.predicate = predicateCompound
        case 1:
            attribute = "category.categoryTag"
            let predicateCompound = NSPredicate(format: "%K CONTAINS[cd] %@", attribute, searchString!)
            request.predicate = predicateCompound
        default:
            attribute = ""
            break
        }
        
        let podcastSorter = NSSortDescriptor(key: sorter, ascending: true)
        request.sortDescriptors = [podcastSorter]
        
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
    func urlDecrypted(url: String) {
        self.url = url
        self.tabController?.hidePlayer()
        toPlayerView()
    }
    
    // Set up the segue to play the podcast send (podcast, podcastUrl)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "AudioSegue4" {
            let destination = segue.destination as! AudioController
            destination.podcast = podcast
            destination.podcastUrl = url
        }
    }
    
    func toPlayerView() {
        performSegue(withIdentifier: "AudioSegue4", sender: Any?.self)
    }
    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String) {
        searchBar.placeholder = searchText
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
        let selectedObject = fetchedResultsController?.fetchedObjects
        
        if (selectedObject?.count != 0) {
            
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            return 1;
            
        } else {
            
            // Display a message when the table is empty
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text             = "Ei hakutuloksia"
            noDataLabel.textColor        = UIColor.white
            noDataLabel.textAlignment    = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            // Display a message when the table is empty
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text             = "Hae PodCatista"
            noDataLabel.textColor        = UIColor.white
            noDataLabel.textAlignment    = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemTableViewCell", for: indexPath ) as! SearchItemTableViewCell
        let selectedObjects = fetchedResultsController?.fetchedObjects
        
        if (selectedObjects?.count != 0) {
            let selectedObject = fetchedResultsController?.object(at: indexPath)
            
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedObject = fetchedResultsController.object(at: indexPath)
        podcast = selectedObject
        
        // Decrypt the selected podcast url
        dataParser.getAndDecryptUrl(podcast: selectedObject, urlDecryptObserver: self)
    }
    
}
