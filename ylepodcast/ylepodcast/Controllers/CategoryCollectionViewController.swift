//
//  CategoryCollectionViewController.swift
//  ylepodcast
//
//  Created by Arto Heino on 13/12/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
class CategoryCollectionViewController: UICollectionViewController {
    
    // MARK: VARIABLES
    
    // Add categories
    // TODO: Should they be hard-coded? YLEAPI will provide all categories! Some categories need to be hard-coded
    var categories = ["Viihde", "Musiikki", "Draama", "Asia", "Kulttuuri", "Historia", "Luonto", "Hartaudet", "Lapset", "Ajankohtaisohjelmat", "Uutiset", "Urheilu"]
    var selectedCategory: String = ""

    // MARK: INITIALIZERS
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: TABLEVIEW
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.categoryLabel.text = categories[indexPath.row]
        let imageView = UIImageView()
        let image = UIImage(named: "defaultImage")
        imageView.image = image
        cell.backgroundView = imageView
        
        // Configure the cell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategory = categories[indexPath.row]
        performSegue(withIdentifier: "CategorySegue", sender: self)
    }
    
    // MARK: NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "CategorySegue" {
            let destination = segue.destination as! PodcastCategoriedTableViewController
            destination.category = self.selectedCategory
        }
    }
    
}
