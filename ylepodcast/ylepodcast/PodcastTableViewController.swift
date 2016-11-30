//
//  PodcastTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 31/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class PodcastTableViewController: UITableViewController, DataParserObserver {
    
    var podcasts = [Podcast]()
    var url: String = ""
    var name: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.podcasts = [Podcast]()
        let dataParser = HttpRequesting()
        
        // FIXME: apply better logic here, now nothing is fetched from the server if CoreData at least one item
        if AppDelegate.fetchPodcastsFromCoreData().count == 0 {
            // Set and Get the podcasts to observer
           dataParser.httpGetPodCasts(parserObserver: self)
        } else {
          podcasts = AppDelegate.fetchPodcastsFromCoreData()
    }
        
    }

    // Run after the podcasts have been parsed in HttpRequesting
    
    func podcastsParsed(podcasts: [Podcast]) {
        
        self.podcasts = podcasts
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.podcasts.count
    }

    //Creates a cell to tableview
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "PodcastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PodcastTableViewCell
        
        cell.collectionLabel.text = self.podcasts[indexPath.row].podcastCollection?["fi"] as? String ?? "Ei otsikkoa saatavilla"
        cell.descriptionLabel.text = self.podcasts[indexPath.row].podcastDescription?["fi"] as? String ?? "Ei kuvausta saatavilla"
        cell.durationLabel.text = self.podcasts[indexPath.row].podcastDuration
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let index = tableView.indexPathForSelectedRow?.row
//        name = self.podcasts[index!].podcastTitle?["fi"]! as? String ?? ""
//        url = self.podcasts[index!].podcastURL!
//        print("URL: " + url)
//        performSegue(withIdentifier: "AudioSegue1", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "AudioSegue1" {
            let destination = segue.destination as! AudioController
            destination.podcastUrl = url
            destination.podcastName = name
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addAction = UITableViewRowAction(style: .normal, title: "Add", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            let usersPlaylistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersPlaylist") as! UsersPlaylistTableViewController

            usersPlaylistController.selectedPodcast = self.podcasts[indexPath.row]

            
            self.show(usersPlaylistController, sender: nil)
        })
        
        addAction.backgroundColor = UIColor.blue
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
