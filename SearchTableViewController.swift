//
//  SearchTableViewController.swift
//  
//
//  Created by A'di Dust on 7/15/20.
//

import UIKit
import Firebase

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    var isOwner = false
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    
    @IBOutlet var userTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var users = [UserTeam]()
    var leagueTeam = [String]()
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var usersArray = [NSDictionary?]()
    var filteredUsers = [UserTeam]()
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = db.collection("Users")
        ref.order(by: "Name", descending: false).whereField("Player", isEqualTo: true).getDocuments { (snapshot, err) in
            if let docs = snapshot?.documents{
                for doc in docs{
                    let data = doc.data()
                    let team: String = "\(data["League"] as! String)" + ", " + "\(data["Team"] as! String)"
                    self.users.append(UserTeam(name: data["Name"] as! String, teamLeague: team, email: data["Email"] as? String ?? ""))
                }
                self.tableView.reloadData()
            }
            else{
                print("error")
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = true
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search User"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredUsers.count
        }
        
        return users.count
    }



    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user: UserTeam
        if isFiltering{
            user = filteredUsers[indexPath.row]
        }
        else{
            user = users[indexPath.row]
        }
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.teamLeague

        return cell
    }
    
    
    func filterContentForSearchText(_ searchText:String) {
        filteredUsers = users.filter{(user1: UserTeam) -> Bool in
            return user1.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index: " + "\(tableView.indexPathForSelectedRow)")
        self.performSegue(withIdentifier: "searchToProfile", sender: self)
    }
    
    struct UserTeam {
        var name : String
        var teamLeague: String
        var email:String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var userTeam: UserTeam
        let indexPath = tableView.indexPathForSelectedRow
        if isFiltering{
            userTeam = filteredUsers[indexPath?.row ?? 0]
        }
        else{
            userTeam = users[indexPath?.row ?? 0]
        }
        
        let VCProfile = segue.destination as? ProfileViewController
        VCProfile?.playerEmail = userTeam.email
        VCProfile?.isOwner = isOwner
    }

}
