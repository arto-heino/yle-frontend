//
//  SettingsTableViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 16/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: INITIALIZER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBarStyle = UINavigationBar.appearance()
        navigationBarStyle.barTintColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        navigationBarStyle.tintColor = UIColor.init(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
}
