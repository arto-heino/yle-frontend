//
//  SearchTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController , UISearchBarDelegate, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults = [Podcast?]()
    var allPods = [Podcast?]()

    override func viewDidLoad() {
    
        
        //Create searchbar
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    
        
    }
    //Updates the search results
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    //filters through keyword(s)
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!)

    }
    //filters the whole data through
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        /// keyword in collections
        let collectionSearchResults = AppDelegate.fetchPodcastsFromCoreData().filter { podcast in
            return (podcast.podcastCollection?["fi"] as? String ?? "Ei titleä").lowercased().contains(searchText.lowercased())
        }
        // keyword in descriptions
        let descriptionSearchResults = AppDelegate.fetchPodcastsFromCoreData().filter { podcast in
            return (podcast.podcastDescription?["fi"] as? String ?? "Ei kuvausta").lowercased().contains(searchText.lowercased())
        }
        // keyword int tags
     //  let tagsSearchResults = AppDelegate.fetchPodcastsFromCoreData().filter { podcast in
          //  for tag in podcast.podcastTags! {
             //   if tag.lowercased().contains(searchText.lowercased()) {
               //     return true
              //  }
           // }
           // return false
       // }
        
        // first set that has all the results
        let set1:Set<Podcast> = Set(collectionSearchResults)
        // set that has also descriptions and tags
        searchResults = Array(set1.union(descriptionSearchResults))
        //.union(tagsSearchResults))

        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Returns results to tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return searchResults.count
        }
        return allPods.count
    }

    //Results to a list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemTableViewCell", for: indexPath ) as! SearchItemTableViewCell

        let podcast = searchResults[indexPath.row]
        
        cell.collectionLabel.text = podcast?.podcastCollection?["fi"] as? String ?? "Ei titleä"
        cell.descriptionLabel.text = podcast?.podcastDescription?["fi"] as? String ?? "Ei kuvausta"
        return cell
    }


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
