//
//  PodcastsTableViewController.swift
//  ylepodcast
//
//  Created by Arto Heino on 03/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class PodcastsTableViewController: UITableViewController {
    // MARK: Properties
    
    var podcasts = [Podcast]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleMeals()
    }
    
    func loadSampleMeals() {
        let photo1 = UIImage(named: "pod1")!
        let podcast1 = Podcast(name: "Ensimmäinen podcast", photo: photo1)!
        
        let photo2 = UIImage(named: "pod2")!
        let podcast2 = Podcast(name: "Toinen podcast", photo: photo2)!
        
        let photo3 = UIImage(named: "pod3")!
        let podcast3 = Podcast(name: "Kolmas podcast", photo: photo3)!
        
        podcasts += [podcast1, podcast2, podcast3]
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
        // #warning Incomplete implementation, return the number of rows
        return podcasts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PodcastsTableViewCell
        let cellIdentifier = "PodcastsTableViewCell"
        let podcast = podcasts[indexPath.row]
        
        cell.nameLabel.text = podcast.name
        cell.photoImageView.image = podcast.photo
        
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
