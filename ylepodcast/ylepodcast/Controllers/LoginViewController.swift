//
//  LoginViewController.swift
//  ylepodcast
//
//  Created by Carla Miettinen on 16/11/2016.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: LABELS
    
    @IBOutlet weak var usernameLabel: UITextField!
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    @IBOutlet weak var loginInfoButton: UIButton!
    
    // MARK: VARIABLES
    
    let login = HttpPosts()
    let users = HttpRequesting()
    var preferences = UserDefaults.standard
    let userLoads = UserLoads()
    
    // MARK: INITIALIZERS
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Check if the user is loged in
        // FIXME: Need to check this from logedin preference, should not read key if not needed.
        if self.preferences.object(forKey: "userKey") != nil{
            LoginDone()
        }else{
            LoginToDo()
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SplashScreenViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: HELPERS
    // TODO: Need to code better validator and crypt the password
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        
        view.endEditing(true)

    }
    
    func checkValidUsername() -> Bool {
        
        let text = usernameLabel.text ?? ""
        return !text.isEmpty
    }
    
    
    func checkValidPassword() -> Bool {
        
        let text = passwordLabel.text ?? ""
        return !text.isEmpty
    }
    func enableLoginButton(enable: Bool) {
        
        loginInfoButton.isEnabled = enable
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        enableLoginButton(enable: checkValidPassword() && checkValidUsername())
    }


    // MARK: ACTIONS
    
    @IBAction func DoLogin(_ sender: Any) {
        
        if(loginInfoButton.titleLabel?.text == "Kirjaudu ulos"){
            userLoads.logOut()
            LoginToDo()
        }else{
            login_now(username:usernameLabel.text!, password: passwordLabel.text!)
        }
        

    }

    func login_now(username:String, password:String){
        
        login.httpLogin(username: username, password: password) { success in
            if success {
                self.LoginDone()
            } else {
                // TODO: Need to show error to user
                self.LoginToDo()

            }
        }
    }
    
    // If login will be true
    func LoginDone(){
        
        let token: String = preferences.object(forKey: "userKey") as? String ?? ""
        let url: String = "http://media.mw.metropolia.fi/arsu/users"
        users.httpGetFromBackend(url: url, token: token){ success in
            let object = success as! [Any]
            for (_, event) in (object.enumerated()) {
                let user = event as! [String:Any]
                let username: String = user["username"] as! String
                if(username == self.preferences.object(forKey: "userName") as! String){
                    self.preferences.set(user["id"], forKey: "userID")
                }
            }
        }
        
        usernameLabel.text = self.preferences.object(forKey: "userName") as? String
        passwordLabel.text = ""
        usernameLabel.isEnabled = false
        passwordLabel.isEnabled = false
        
        
        loginInfoButton.isEnabled = true
        
        
        loginInfoButton.setTitle("Kirjaudu ulos", for: .normal)
        
        // Get all user-related stuff from CoreData/backend
        userLoads.getPlaylists()
        userLoads.getHistory()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        self.show(vc, sender: nil)
    }
    
    // If user is not logged in show these
    func LoginToDo(){
        
        usernameLabel.text = ""
        usernameLabel.isEnabled = true
        passwordLabel.isEnabled = true
        
        loginInfoButton.isEnabled = true
        
        
        loginInfoButton.setTitle("Kirjaudu sisään", for: .normal)
    }

}
