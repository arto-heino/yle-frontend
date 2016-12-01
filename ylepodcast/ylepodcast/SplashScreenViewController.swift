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
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SplashScreenViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
        //Calls this function when the tap is recognized.
        func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
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
        let tb = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        self.show(tb, sender: nil)
        navigationItem.hidesBackButton = true
        
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
