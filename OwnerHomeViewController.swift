//
//  OwnerHomeViewController.swift
//  Asgard
//
//  Created by A'di Dust on 7/7/20.
//  Copyright © 2020 A'di Dust. All rights reserved.
//

import UIKit

class OwnerHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func calendarBut(_ sender: Any) {
        performSegue(withIdentifier: "homeOwnerToCalendar", sender: self)
    }
    
    @IBAction func searchBut(_ sender: Any) {
        performSegue(withIdentifier: "homeOwnerToSearch", sender: self)
    }
    
    @IBAction func changeScoreBut(_ sender: Any) {
        performSegue(withIdentifier: "homeOwnerToChangeScore", sender: self)
    }
    
    @IBAction func teamManageBut(_ sender: Any) {
        //TODO: tell Profile VC that it's the team
        performSegue(withIdentifier: "homeOwnerToTeamLeague", sender: self)
    }
    
    @IBAction func leagueManageBut(_ sender: Any) {
        //TODO: tell Profile VC that it's the league
        performSegue(withIdentifier: "homeOwnerToTeamLeague", sender: self)
    }
    
    @IBAction func signOutBut(_ sender: Any) {
        performSegue(withIdentifier: "homeOwnerToEntry", sender: self)
    }
    
    //allows editing of all profiles
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VCProfile = segue.destination as? SearchTableViewController
        VCProfile?.isOwner = true
    }
}
