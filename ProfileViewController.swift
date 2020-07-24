//
//  ProfileViewController.swift
//  Asgard
//
//  Created by A'di Dust on 7/7/20.
//  Copyright © 2020 A'di Dust. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    //buttons variables
    @IBOutlet weak var searchBut: UIButton!
    @IBOutlet weak var signOutBut: UIButton!
    @IBOutlet weak var editProfileBut: UIButton!
    @IBOutlet weak var homeBut: UIButton!
    @IBOutlet weak var scheduleBut: UIButton!
    @IBOutlet weak var changePlayerPicBut: UIButton!
    @IBOutlet weak var changeTeamPicBut: UIButton!
    @IBOutlet weak var emailBut: UIButton!
    @IBOutlet weak var phoneBut: UIButton!
    
    //picture variables
    @IBOutlet weak var playerPic: UIImageView!
    @IBOutlet weak var teamPic: UIImageView!
    
    //lables and text fields variables
    @IBOutlet weak var playerNameLab: UILabel!
    @IBOutlet weak var opponentTeamLabel: UILabel!
    @IBOutlet weak var timeDayLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var handicapLabel: UILabel!
    @IBOutlet weak var playerRankLabel: UILabel!
    @IBOutlet weak var teamRankLabel: UILabel!
    
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    //switch varaible
    @IBOutlet weak var editSwitch: UISegmentedControl!
    
    
    //general variables
    var isOwner = false
    var isPlayer = false
    var playerPicked = ""
    var playerEmail = ""
    var edit = false
    var imagePicked = 0
    let db = Firestore.firestore()
    let teamURLString = "https://webstockreview.net/images250_/axe-clipart-cross-axe-2.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide everything but the search button
        searchBut.isHidden = false
        signOutBut.isHidden = true
        editProfileBut.isHidden = true
        homeBut.isHidden = true
        scheduleBut.isHidden = true

        playerNameTextField.isHidden = true
        emailTextField.isHidden = true
        phoneTextField.isHidden = true
        changeTeamPicBut.isHidden = true
        changePlayerPicBut.isHidden = true
        
        fillInformation()
        
        //check if profile is palyer's account
        let defaults = UserDefaults.standard
        if playerEmail == defaults.string(forKey: "Email"){
            isPlayer = true
        }
        
        if isOwner || isPlayer{
            editSwitch.isHidden = false
            editSwitch.isEnabled = true
        }
        else{
            editSwitch.isHidden = true
            editSwitch.isEnabled = false
        }
    }
    
    //find and fill in all information
    func fillInformation(){
        emailBut.setTitle(playerEmail, for: .normal)
        let ref = db.collection("Users").document(playerEmail)
        ref.getDocument { (snapshot, err) in
            if let data = snapshot?.data(){
                
                //set all player informational labels
                self.playerNameLab.text = data["Name"] as? String ?? ""
                self.phoneBut.setTitle(String(data["Phone"] as? Int ?? 0000000000), for: .normal)
                self.teamLabel.text = "\(data["Team"] as? String ?? "")"
                self.averageLabel.text = "Average: " + "\(data["Average"] as? Int ?? 0)"
                self.handicapLabel.text = "Handicap: " + "\(data["Handicap"] as? Int ?? 0)"
                self.playerRankLabel.text = "Player Rank: " + "\(data["Rank"] as? Int ?? 0)"
                
                
                //set player picture
                 print("before player")
                let playerPicString = data["Picture"] as? String
                self.playerPic.image = playerPicString?.toImage(Utilities.playerURLString)
                
                
                //set team information
                if data["Team"] as? String ?? "" == "Not Available" {
                    self.teamPic.image = Utilities.teamURLString.toImage(self.teamURLString)
                    self.teamRankLabel.text = "Team Rank: N/A"
                }
                else{
                let teamRef = self.db.collection("Teams").document(data["Team"] as? String ?? "")
                teamRef.getDocument { (snapshot, err) in
                    if let snapshot = snapshot, snapshot.exists{
                        //set team rank
                        self.teamRankLabel.text = "Team Rank: " + "\(data["Rank"] as? Int ?? 0)"
                            
                        let teamPicString = data["Picture"] as? String
                        self.teamPic.image = teamPicString?.toImage(Utilities.teamURLString)
                        
                    }
                    else{
                        self.playerPic.image = Utilities.teamURLString.toImage(self.teamURLString)
                        self.teamRankLabel.text = "Team Rank: N/A"
                    }
                    }
                    
                    
                    
                    //find and set opponent team and calendar date
                    let calendarRef = self.db.collection("Games")
                    calendarRef.order(by: "DayTime", descending: false).whereField("Teams", arrayContains: data["Team"] as? String ?? "").limit(to: 1).getDocuments { (snapshot, err) in
                        if let docs = snapshot?.documents{
                            //find and set date
                            let datas = docs[0].data()
                            if (datas["DayTime"] as? Timestamp) != nil{
                                let dt = (datas["DayTime"] as! Timestamp).dateValue()
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm E, d MMM"
                                self.timeDayLabel.text = formatter.string(from: dt)
                                
                                
                                //find and set opponent
                                let arr = datas["Teams"] as! Array<String>
                                for team in arr{
                                    if team != data["Team"] as? String ?? "" {
                                        self.opponentTeamLabel.text = team
                                    }
                                }
                            }
                            else{
                                self.opponentTeamLabel.text = "No Upcoming Game"
                            }
                        }
                        else{
                            print(err)
                        }
                }
                    }
                    
                    
                    
                }
            
            else{
                print(err)
            }
        }
    }
    
    
    
    
    
    //buttons
    
    
    //email button
    @IBAction func emailPress(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = emailBut.currentTitle
        
        let alert = UIAlertController(title: "Email is now copied to clipboard.", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    //phone button
    @IBAction func phonePress(_ sender: Any) {
        let phoneNumber = phoneBut.currentTitle ?? ""
        if let phoneURL = NSURL(string: ("tel://" + phoneNumber)) {

                let alert = UIAlertController(title: ("Call " + phoneNumber + "?"), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
                    UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    
    
    
    
    
    //switch
    @IBAction func `switch`(_ sender: Any) {
        switch editSwitch.selectedSegmentIndex {
        case 0:
            changeTeamPicBut.isHidden = true
            changeTeamPicBut.isEnabled = false
            changePlayerPicBut.isHidden = true
            changePlayerPicBut.isEnabled = false
            playerNameTextField.isHidden = true
            playerNameTextField.isEnabled = false
            emailTextField.isHidden = true
            emailTextField.isEnabled = false
            phoneTextField.isHidden = true
            phoneTextField.isEnabled = false
            
            emailBut.isHidden = false
            emailBut.isEnabled = true
            phoneBut.isHidden = false
            phoneBut.isEnabled = true
            playerNameLab.isHidden = false
        case 1:
            changeTeamPicBut.isHidden = false
            changeTeamPicBut.isEnabled = true
            changePlayerPicBut.isHidden = false
            changePlayerPicBut.isEnabled = true
            playerNameTextField.isHidden = false
            playerNameTextField.isEnabled = true
            emailTextField.isHidden = false
            emailTextField.isEnabled = true
            phoneTextField.isHidden = false
            phoneTextField.isEnabled = true
            
            emailBut.isHidden = true
            emailBut.isEnabled = false
            phoneBut.isHidden = true
            phoneBut.isEnabled = false
            playerNameLab.isHidden = true
        default:
            break
        }
    }
    
    
    
    
    
    
    

    //shows segue buttons if collapsed, hides if expanded
    @IBAction func expandButs(_ sender: Any) {
        signOutBut.isHidden = !signOutBut.isHidden
        editProfileBut.isHidden = !editProfileBut.isHidden
        homeBut.isHidden = !homeBut.isHidden
        scheduleBut.isHidden = !scheduleBut.isHidden
    }

    
    @IBAction func viewEdit(_ sender: Any) {
        switch editSwitch.selectedSegmentIndex{
        case 0:
            playerNameTextField.isHidden = true
            emailTextField.isHidden = true
            phoneTextField.isHidden = true
            changeTeamPicBut.isHidden = true
            changePlayerPicBut.isHidden = true
            emailBut.isHidden = false
            playerNameLab.isHidden = false
            phoneBut.isHidden = false
        case 1:
            playerNameTextField.isHidden = false
            emailTextField.isHidden = false
            phoneTextField.isHidden = false
            changeTeamPicBut.isHidden = false
            changePlayerPicBut.isHidden = false
            emailBut.isHidden = true
            playerNameLab.isHidden = true
            phoneBut.isHidden = true
        default:
            break
        }
    }
    
    
    //update user name
    @IBAction func playerNameChange(_ sender: Any) {
        let oldName = playerNameLab.text
        let newName = playerNameTextField.text ?? playerNameLab.text
        
        //change player name in Users database
        db.collection("Users").document(playerEmail).setData(["Name": newName!], merge: true)
        
        //change player name in Team database
        let team = teamLabel.text ?? ""
        print(team)
        if team != "Not Available"{
        db.collection("Teams").document(team).getDocument { (snapshot, err) in
            if let data = snapshot?.data(){
                let nameArr = data["Players"] as! [String]
                var newArr: [String] = []
                for name in nameArr {
                    if name == oldName{
                        newArr.append(newName!)
                    }
                    else{
                        newArr.append(name)
                    }
                }
                self.db.collection("Teams").document(self.teamLabel.text ?? "").setData(["Players": newArr], merge: true)
            }
            else{
                print("error")
            }
        }
        }
        
        playerNameLab.text = newName
    }
    
    
    
    //update email
    @IBAction func emailChange(_ sender: Any) {
        let newEmail = emailTextField.text ?? emailBut.currentTitle
        
        //change player name in Users database
        db.collection("Users").document(playerEmail).setData(["Email": newEmail!], merge: true)
        
        
        emailBut.setTitle(newEmail, for: .normal)
    }
    
    
    
    //update phone
    @IBAction func phoneChange(_ sender: Any) {
        let newPhone = phoneTextField.text ?? phoneBut.currentTitle
        
        //change player name in Users database
        db.collection("Users").document(playerEmail).setData(["Email": newPhone!], merge: true)
        
        
        emailBut.setTitle(newPhone, for: .normal)
    }

    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageView = info[UIImagePickerController.InfoKey.originalImage] as! UIImage?{
            if imagePicked == 0{
                playerPic.image = imageView
                saveProfilePic()
            }
            if imagePicked == 1{
                teamPic.image = imageView
                saveTeamPic()
            }
        }
        else{
            print("image error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //change player picture
    @IBAction func changePlayerPic(_ sender: Any) {
        imagePicked = 0
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true)
    }
    
    func saveProfilePic(){
        let playerString = playerPic.image?.toString()
        db.collection("Users").document(playerEmail).setData(["Picture": playerString], merge: true)
    }
    
    
    
    //change team picture
    @IBAction func changeTeamPic(_ sender: Any) {
        imagePicked = 1
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true)
    }
    
    
    func saveTeamPic(){
        let teamString = teamPic.image?.toString()
        
        db.collection("Users").document(playerEmail).getDocument { (snapshot, err) in
            if let data = snapshot?.data(){
                self.db.collection("Teams").document(data["Team"] as? String ?? "").setData(["Picture": teamString ?? Utilities.teamURLString], merge: true)
            }
            else{
                print("error")
            }
        }
    }
    
    
    //button time
    
    @IBAction func signOut(_ sender: Any) {
        performSegue(withIdentifier: "profileToEntry", sender: self)
    }
    
    @IBAction func editProfile(_ sender: Any) {
        //change from search to edit
    }
    
    @IBAction func home(_ sender: Any) {
        performSegue(withIdentifier: "profileToHome", sender: self)
    }
    
    @IBAction func schedule(_ sender: Any) {
        performSegue(withIdentifier: "profileToCalendar", sender: self)
    }
    
    
   
}

extension String {
       func toImage(_ noString: String) -> UIImage? {
           if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
               return UIImage(data: data)
           }
        return nil
       }
   }

extension UIImage {
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
