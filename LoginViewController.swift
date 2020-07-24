//
//  LoginViewController.swift
//  Asgard
//
//  Created by A'di Dust on 6/6/20.
//  Copyright © 2020 A'di Dust. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLab: UILabel!
    
    //variables
    var cleanedEmail = ""
    var cleanedPassword = ""
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLab.isHidden = true
    }
    
    //checks email and password and logs in
    @IBAction func logIn(_ sender: Any) {
        //Create cleaned versions of text field
        cleanedEmail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        cleanedPassword = password.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        
        //Validate text fields
        if cleanedEmail == "" || cleanedPassword == ""{
            showError("Please fill in all fields")
        }
        
        //Sign-in user
        
        else{
            Auth.auth().signIn(withEmail: cleanedEmail, password: cleanedPassword) { (result, error) in
                if error != nil {
                    //couldn't sign-in
                    self.showError("Could not sign in")
                }
                else{
                    //hide all
                    self.errorLab.isHidden = true
                    self.email.text = ""
                    self.password.text = ""
                    
                    //set default eamil and go to home
                    let defaults = UserDefaults.standard
                    defaults.set(self.cleanedEmail, forKey: "Email")
                    self.ownerOrPlayer()
                }
            }
        }
    }
    
    //see if player or owner and takes to respective home
    func ownerOrPlayer(){
        let ref = db.collection("Users").document(cleanedEmail)
        ref.getDocument { (snapshot, err) in
            if let data = snapshot?.data() {
                if(data["Player"] as! Bool){
                    self.performSegue(withIdentifier: "loginToHome", sender: self)
                }
                else{
                    self.performSegue(withIdentifier: "loginToOwnerHome", sender: self)
                }
            }
            else{
                self.showError("Could not find player data.")
            }
        }
    }
    
    
    //show error message
    func showError (_ message:String){
        errorLab.text = message
        errorLab.isHidden = false
    }
}
