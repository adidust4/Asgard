//
//  HomeViewController.swift
//  Asgard
//
//  Created by A'di Dust on 6/14/20.
//  Copyright © 2020 A'di Dust. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class HomeViewController: UIViewController {
    
    
  //Lables and Pictures
    @IBOutlet weak var teamPic: UIImageView!
    @IBOutlet weak var teamRankLab: UILabel!
    @IBOutlet weak var teamTotalLabel: UILabel!
    @IBOutlet weak var teamTrophyPic: UIImageView!
    @IBOutlet weak var playerPic: UIImageView!
    @IBOutlet weak var playerRankLab: UILabel!
    @IBOutlet weak var playerTotalLab: UILabel!
    @IBOutlet weak var playerTrophyPic: UIImageView!
    @IBOutlet weak var averageLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var teamAgainstLab: UILabel!
    @IBOutlet weak var teamRankingsLab: UILabel!
    @IBOutlet weak var playerRankingsLab: UILabel!
    @IBOutlet weak var leagueLab: UILabel!
    
    //Buttons
    @IBOutlet weak var homeBut: UIButton!
    @IBOutlet weak var signOutBut: UIButton!
    @IBOutlet weak var editProfileBut: UIButton!
    @IBOutlet weak var searchBut: UIButton!
    @IBOutlet weak var scheduleBut: UIButton!
    @IBOutlet weak var searchTeamBut: UIButton!
    
    //general variables
    let db = Firestore.firestore()
    var editProfile = false
    let bronzeTrophyURL = "https://firebasestorage.googleapis.com/v0/b/asgard-ec545.appspot.com/o/Screen%20Shot%202020-07-11%20at%203.10.27%20PM.png?alt=media&token=39a884cd-7257-4f82-8f34-0408639b683a"
    let silverTrophyURL = "https://firebasestorage.googleapis.com/v0/b/asgard-ec545.appspot.com/o/Screen%20Shot%202020-07-11%20at%203.10.13%20PM.png?alt=media&token=4d0dad12-08c2-4f8b-8864-731ca9174b7e"
    let goldTrophyURL = "https://firebasestorage.googleapis.com/v0/b/asgard-ec545.appspot.com/o/Screen%20Shot%202020-07-11%20at%203.10.18%20PM.png?alt=media&token=040ee5aa-e631-44d6-8651-2549a8756565"
    let mehTrophyURL = "https://i0.wp.com/vrworld.com/wp-content/uploads/2014/07/Meh1.png?resize=300%2C136"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //hide menu
        signOutBut.isHidden = true
        editProfileBut.isHidden = true
        searchBut.isHidden = true
        scheduleBut.isHidden = true
        searchTeamBut.isHidden = true
        
        //find info
        setPlayerInformation()
    }
    
    //set screen
 
    //set labels, pictures, calculate trophies for player information
    func setPlayerInformation(){
        let defaults = UserDefaults.standard
        
        //PLAYER INFORMATION SET
        //first set rank,league, team, and average labels
        let ref = db.collection("Users").document(defaults.string(forKey: "Email") ?? "")
        ref.getDocument { (snapshot, err) in
            if let data = snapshot?.data() {
                self.playerRankLab.text = "\(data["Rank"] as? Int ?? 0)"
                self.averageLab.text = "\(data["Average"] as? Int ?? 1)"
                self.leagueLab.text = data["League"] as? String ?? "No League Affiliation"
                self.teamRankingsLab.text = "\(data["Team"] as? String ?? "Unavailable Team") Rankings"
                self.playerRankingsLab.text = "\(data["Name"] as? String ?? "Player")'s Rankings"
                
                //find and set player trophy
                let playerRank = data["Rank"] as? Int ?? 0
                if playerRank == 1{
                    print("#1")
                    let goldURL = URL(string: self.goldTrophyURL)
                    let goldImageData = try? Data(contentsOf: goldURL!)
                    self.playerTrophyPic.image = UIImage(data: goldImageData!)
                }
                else if playerRank == 2{
                    let silverURL = URL(string: self.silverTrophyURL)
                    let silverImageData = try? Data(contentsOf: silverURL!)
                    self.playerTrophyPic.image = UIImage(data: silverImageData!)
                }
                else if playerRank == 3{
                    let bronzeURL = URL(string: self.bronzeTrophyURL)
                    let bronzeImageData = try? Data(contentsOf: bronzeURL!)
                    self.playerTrophyPic.image = UIImage(data: bronzeImageData!)
                }
                else{
                    let mehURL = URL(string: self.mehTrophyURL)
                    let mehImageData = try? Data(contentsOf: mehURL!)
                    self.playerTrophyPic.image = UIImage(data: mehImageData!)
                }
                
                //get and set player picture
                let stringURL = data["Picture"] as? String ?? ""
                let url = URL(string: stringURL)
                let imageData = try? Data(contentsOf: url!)
                self.playerPic.image = UIImage(data: imageData!)
                
                
                
                //get and set total number of players
                let usersRef = self.db.collection("Users")
                usersRef.whereField("League", isEqualTo: data["League"] as? String ?? "").getDocuments { (snapshot, err) in
                    if let documents = snapshot?.documents {
                        var count = 0
                        for _ in documents{
                            count = count + 1
                        }
                        self.playerTotalLab.text = "/\(count)"
                    }
                    else{
                        print("error")
                    }
                }
                
                
                //find and set team info
                let refTeam = self.db.collection("Teams").document(data["Team"] as? String ?? "")
                refTeam.getDocument { (snapshot, err) in
                    if let data = snapshot?.data() {
                        self.teamRankLab.text = "\(data["Rank"] as? Int ?? 0)"
                        let league = data["League"] as? String ?? ""
                        
                        //find and set player trophy
                        let teamRank = data["Rank"] as? Int ?? 0
                        if teamRank == 1{
                            print("#1")
                            let goldURL = URL(string: self.goldTrophyURL)
                            let goldImageData = try? Data(contentsOf: goldURL!)
                            self.teamTrophyPic.image = UIImage(data: goldImageData!)
                        }
                        else if teamRank == 2{
                            let silverURL = URL(string: self.silverTrophyURL)
                            let silverImageData = try? Data(contentsOf: silverURL!)
                            self.teamTrophyPic.image = UIImage(data: silverImageData!)
                        }
                        else if teamRank == 3{
                            let bronzeURL = URL(string: self.bronzeTrophyURL)
                            let bronzeImageData = try? Data(contentsOf: bronzeURL!)
                            self.teamTrophyPic.image = UIImage(data: bronzeImageData!)
                        }
                        else{
                            let mehURL = URL(string: self.mehTrophyURL)
                            let mehImageData = try? Data(contentsOf: mehURL!)
                            self.teamTrophyPic.image = UIImage(data: mehImageData!)
                        }
                        
                        
                        //get and set team picture
                        let stringURLteam = data["Picture"] as? String ?? ""
                        let urlteam = URL(string: stringURLteam)
                        let imageDatateam = try? Data(contentsOf: urlteam!)
                        self.teamPic.image = UIImage(data: imageDatateam!)
                        
                        //get and set total number of teams
                        let teamsRef = self.db.collection("Teams")
                        teamsRef.whereField("League", isEqualTo: league).getDocuments { (snapshot, err) in
                            if let document = snapshot?.documents {
                                var count = 0
                                for _ in document{
                                    count = count + 1
                                }
                                self.teamTotalLabel.text = "/\(count)"
                            }
                            else{
                                print("error")
                            }
                        }

                    }
                    else{
                        print("error")
                    }
                }
                
                
                
                //find and set opponent team and calendar date
                let calendarRef = self.db.collection("Games")
                calendarRef.order(by: "DayTime", descending: false).whereField("Teams", arrayContains: data["Team"] as? String ?? "").limit(to: 1).getDocuments { (snapshot, err) in
                    if let docs = snapshot?.documents{
                        
                        //find and set date
                        let datas = docs[0].data()
                        let date = (datas["DayTime"] as! Timestamp).dateValue()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm E, d MMM"
                        self.timeLab.text = formatter.string(from: date)
                        
                        //find and set opponent
                        let arr = datas["Teams"] as! Array<String>
                        for team in arr{
                            if team != data["Team"] as? String ?? "" {
                                self.teamAgainstLab.text = team
                            }
                        }
                    }
                    else{
                        print("error")
                    }
                }
                
            }
            else{
                print("error")
            }
        }
    }
    
    
    
    

    
    //button time
    
    
    
    //if menu is hidden, show menu, otherwise hide it
    @IBAction func hideShowMenu(_ sender: Any) {
        let hidden = !signOutBut.isHidden
        signOutBut.isHidden = hidden
        searchTeamBut.isHidden = hidden
        editProfileBut.isHidden = hidden
        searchBut.isHidden = hidden
        scheduleBut.isHidden = hidden
    }
    
    
    //these are all segues for the drop-down to the next place...
    
    @IBAction func signOut(_ sender: Any) {
        performSegue(withIdentifier: "homeToEntry", sender: self)
    }
    
    @IBAction func editProfile(_ sender: Any) {
        
        //TODO: tell Profile VC that it's the user
        editProfile = true
        
        performSegue(withIdentifier: "homeToProfile", sender: self)
    }
    
    @IBAction func searchPlayers(_ sender: Any) {
        performSegue(withIdentifier: "homeToSearch", sender: self)
    }
    
 
    @IBAction func schedule(_ sender: Any) {
        performSegue(withIdentifier: "homeToCalendar", sender: self)
    }
 
    //allows editing of own profile and takes to own profile if editProfile is true
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VCProfile = segue.destination as? ProfileViewController
        VCProfile?.isPlayer = editProfile
        if editProfile{
            VCProfile?.playerEmail = UserDefaults.standard.string(forKey: "Email") ?? ""
        }
    }
}



