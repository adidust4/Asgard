//
//  SignUpViewController.swift
//  Asgard
//
//  Created by A'di Dust on 6/6/20.
//  Copyright © 2020 A'di Dust. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var coachPassword: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var playerCoachSegment: UISegmentedControl!
    
    var realCoachPassword = "CoAche5#"
    var coach = false
    
    var cleanedEmail = ""
    var cleanedPassword = ""
    var cleanedCoachPassword = ""
    var cleanedName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true
    }
    
    
    
    
    
    //set coach true if user clicks coach and hides coach password if player
    @IBAction func coachChange(_ sender: Any) {
        switch playerCoachSegment.selectedSegmentIndex {
        case 0:
            coach = false
            coachPassword.isHidden = true
            coachPassword.isEnabled = false
        case 1:
            coach = true
            coachPassword.isHidden = false
            coachPassword.isEnabled = true
        default:
            break
        }
    }
    
    
    
    
    
    
    func validateFields() -> String? {
        
        
        //create cleaned versions of information
        cleanedEmail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        cleanedPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedCoachPassword = coachPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        cleanedName = name.text?.trimmingCharacters(in: .newlines) ?? ""
        
        
        //check that all fields are filled in
        if (cleanedEmail == "" || cleanedPassword == "" || cleanedName == ""){
            
            return "Please fill in all fields."
            
        }
        
        
        //check that if coach is true, coach is filled
        if coach == true && cleanedCoachPassword == "" {
            
            return "Please fill in all fields."
            
        }
        
        
        //checks that if coach is true, coach password is correct
        if coach == true && cleanedCoachPassword != realCoachPassword{
            return "Please use correct coach password or switch to become a player."
        }
            
        
        //Check if the password is secure
        if Utilities.isValidPassword(testStr: cleanedPassword) == false{
            
            //Password isn't secure enough
            return "Please make sure your password has at least 8 characters, has at least one uppercase and lowercase letter, and at least one number."
            
        }
        
        
        return nil
    }
    
    
    
    
    
    
    @IBAction func enter(_ sender: UIButton) {
        //validate the fields
        let error = validateFields()
        
        
        if error != nil {
            //there's something wrong, so show message
            showError(error!    )
        }
            
            
        else {
            //Create the user
            Auth.auth().createUser(withEmail: cleanedEmail, password: cleanedPassword) { (result, err) in
                //Check for errors
                if err != nil {
                    //there was an error
                    self.showError("Error creating user")
                }
                else{
                //user created so save information
                    let db = Firestore.firestore()
                    db.collection("Users").document(self.cleanedEmail).setData(["Average":0, "Email":self.cleanedEmail, "Handicap":0, "Name":self.cleanedName,"Picture":"", "Player": !self.coach, "Rank": 0, "Team": "Not Available", "Phone":0000000000]) { (error) in
                        
                        if error != nil {
                            //show error message
                            self.showError("User information could not be saved")
                        }
                        
                        else{
                            //save defaults and transition to home screen
                            let defaults = UserDefaults.standard
                            defaults.set(self.cleanedEmail, forKey: "Email")
                            defaults.set(self.cleanedName, forKey: "Name")
                            self.email.text = ""
                            self.password.text = ""
                            self.coachPassword.text = ""
                            self.name.text = ""
                            self.errorLabel.isHidden = true
                            self.ownerOrPlayer()
                        }
                    }
                }
            }
            
        }
    }
    
    //see if player or owner and takes to respective home
    func ownerOrPlayer(){
        if(coach){
            self.performSegue(withIdentifier: "signUpToOwnerHome", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "signUpToHome", sender: self)
        }
    }
    
    //show error message
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.isHidden = false
    }

}
