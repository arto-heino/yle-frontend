//
//  ViewController.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    

    

    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.white


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

