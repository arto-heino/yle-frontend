//
//  HistoryTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 04/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var podcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func loadSamplePods() {
            
            let photo1 = UIImage(named: "defaultImage")!
            let podcast1 = Podcast(collection: "lolasdasdasdasd", photo: photo1, description: "jeejeeasdasdasdasdasd asd asdasdasdasd asd asdasdasdasdasd sad asdasdasdasd asd asdasdasdasd asd asd ", duration: "10.15")!
            
            let podcast2 = Podcast(collection: "yo", photo: photo1, description: "tosi jee", duration: "20.00")!
            
            let podcast3 = Podcast(collection: "liibalaaba", photo: photo1, description: "testitesti3", duration: "00.33")!
            
            
            podcasts += [podcast1, podcast2, podcast3]
            
        }
        
        
        
        loadSamplePods()
        
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
        
        return podcasts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PodcastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PodcastTableViewCell
        
        let podcast = podcasts[indexPath.row]
        
        cell.collectionLabel.text = podcast.collection
        cell.podcastImageView.image = podcast.photo
        cell.descriptionLabel.text = podcast.description
        cell.durationLabel.text = podcast.duration
        
        
        return cell
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
