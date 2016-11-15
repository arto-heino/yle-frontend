//
//  SearchTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController , UISearchBarDelegate{
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults = [Podcast?]()

    override func viewDidLoad() {
    
        
        //luodaan searchbar
        super.viewDidLoad()
        //searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    
        
        //AppDelegate.loadSamplePods()
    }
    //Päivittää hakutulokset
    /*func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    //filtteröi hakusanan mukaan
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!)

    }
    //filtteröi koko datasta hakusanan mukaiset podcastit
    /*
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        /// etsitään collectioneista hakusanalla
        let collectionSearchResults = AppDelegate.dummyData.filter { podcast in
            return podcast.collection.lowercased().contains(searchText.lowercased())
        }
        // etsitään descriptioneista hakusanalla
        let descriptionSearchResults = AppDelegate.dummyData.filter { podcast in
            return podcast.description.lowercased().contains(searchText.lowercased())
        }
        // etsitään tageista hakusanalla
        let tagsSearchResults = AppDelegate.dummyData.filter { podcast in
            for tag in podcast.tags {
                if tag.lowercased().contains(searchText.lowercased()) {
                    return true
                }
            }
            return false
        }
        
        // eka setti joka sisältää collection-osumat
        let set1:Set<Podcast> = Set(collectionSearchResults)
        // sekä description-osumat että tags-osumat
        searchResults = Array(set1.union(descriptionSearchResults).union(tagsSearchResults))
        
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //palauttaa listviewiin haun tulokset
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    //piirtää tulokset listaan
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemTableViewCell", for: indexPath ) as! SearchItemTableViewCell

        let podcast = searchResults[indexPath.row]
        cell.collectionLabel.text = podcast?.collection
        cell.descriptionLabel.text = podcast?.description

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
 */
 */

}
