//
//  SplashScreenViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 22/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit


//controls the splash screen ja registeration

class SplashScreenViewController: UIViewController {
    
    
    
    @IBOutlet weak var regWithEmailLabel: UITextField!

    @IBOutlet weak var regWithUsernameLabel: UITextField!
    
    @IBOutlet weak var regWithPasswordLabel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func registerButton(_ sender: Any) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
