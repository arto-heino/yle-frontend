//
//  SplashScreenViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 22/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    // MARK: LABELS
    
    @IBOutlet weak var regWithEmailLabel: UITextField!

    @IBOutlet weak var regWithUsernameLabel: UITextField!
    
    @IBOutlet weak var regWithPasswordLabel: UITextField!
    
    // MARK: VARIABLES
    
    let register = HttpPosts()
    let getBackend = HttpRequesting()
    
    // MARK: INITIALIZER
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SplashScreenViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: HELPERS
    
        //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        register_now(username: regWithUsernameLabel.text!, password: regWithPasswordLabel.text!, email: regWithEmailLabel.text!)
    }
    
    // TODO: Check if username is already in backend
    /*func checkUsername(username: String){
        
        let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywidXNlcm5hbWUiOiJtb2kiLCJlbWFpbCI6Im1vaUBleGFtcGxlLmNvbSIsImlzX2FkbWluIjpudWxsLCJkYXRlIjoiMjAxNi0xMS0xNVQxNjowMToyMy4wMDBaIiwiaWF0IjoxNDc5ODkzNTAxLCJleHAiOjE1MTE0Mjk1MDF9.7J3SHaIBZl5Q5kcKTa_7S8spYADzW9gxzB260OTQAWI"
        let url: String = "http://media.mw.metropolia.fi/arsu/users/"
        
        getBackend.httpGetFromBackend(url: url, token: token) { success in
            for (_, event) in (success.enumerated()) {
                var usernameToCheck: String
                usernameToCheck = event["username"] as! String
                if(usernameToCheck == username){
                    //Need to show error
                    print("Username is on use")
                }
            }
        }
    }*/
    
    // FIXME: Need to show user success or error
    func register_now(username:String, password:String, email:String) {
        
        register.httpRegister(username: username, password: password, email: email) { success in
            if success {
                let tb = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                self.show(tb, sender: nil)
                self.navigationItem.hidesBackButton = true
            } else {
                // Need to show error
                print("Error when creating a user")
            }
        }
    }

}
