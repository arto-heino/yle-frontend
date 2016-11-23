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
    
    let register = HttpPosts()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func registerButton(_ sender: Any) {
        register_now(username: regWithUsernameLabel.text!, password: regWithPasswordLabel.text!, email: regWithEmailLabel.text!)
    }
    
    func register_now(username:String, password:String, email:String)
    {
        register.httpRegister(username: username, password: password, email: email) { success in
            if success {
                print("Tunnus tehty")
            } else {
                print("Tunnusta ei tehty")
                
            }
        }
        
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
