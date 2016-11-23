//
//  LoginViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 16/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UITextField!
    
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    
    @IBOutlet weak var loginInfoButton: UIButton!
    
    let login = HttpPosts()
    let podcast = HttpRequesting()
    var preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.preferences.object(forKey: "userKey") != nil
        {
            LoginDone()
        }
        else
        {
            LoginToDo()
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func DoLogin(_ sender: AnyObject) {
        
        if(loginInfoButton.titleLabel?.text == "Kirjaudu ulos")
        {
            self.preferences.removeObject(forKey: "userKey")
            self.preferences.removeObject(forKey: "userName")

            LoginToDo()
        }
        else{
            login_now(username:usernameLabel.text!, password: passwordLabel.text!)
        }
        
    }
    
    func login_now(username:String, password:String)
    {
        login.httpLogin(username: username, password: password) { success in
            if success {
                self.LoginDone()
            } else {
                self.LoginToDo()

            }
        }
        
    }
    
    func LoginDone()
    {
        let id: String = self.preferences.object(forKey: "userID") as? String ?? ""

        let url: String = "http://media.mw.metropolia.fi/arsu/playlists/user/" + id
        podcast.httpGetFromBackend(url: url, token: self.preferences.object(forKey: "userKey") as? String) { success in
            print(success)
        }
        
        
        usernameLabel.text = self.preferences.object(forKey: "userName") as? String
        passwordLabel.text = ""
        usernameLabel.isEnabled = false
        passwordLabel.isEnabled = false
        
        loginInfoButton.isEnabled = true
        
        
        loginInfoButton.setTitle("Kirjaudu ulos", for: .normal)
    }
    
    func LoginToDo()
    {
        usernameLabel.text = ""
        usernameLabel.isEnabled = true
        passwordLabel.isEnabled = true
        
        loginInfoButton.isEnabled = true
        
        
        loginInfoButton.setTitle("Kirjaudu sisään", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
