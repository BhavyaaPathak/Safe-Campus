//
//  SearchTableViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/19/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func filterValueSelected (filters: [String: String?])
}

class SearchTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    var filteredIncidents = [SCIncident]()
    var zip: String!
    var selectedIncident: SCIncident!
    var incidentList = [SCIncident]()
    var displayFiltered = false
    var fil: [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create Title
        self.navigationItem.title = "Search Incidents";
        self.setupSearchController()
        //Load Incident data
        self.loadDataForTable()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setupSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        //For Filter
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "filter"), for: .bookmark, state: .normal)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search By title"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        let cell = UINib(nibName: "IncidentTableViewCell", bundle: nil)
        self.tableView.register(cell, forCellReuseIdentifier: "IncidentCell")
    }
    
    func loadDataForTable() {
        self.zip = CurrentUser.shared.getLocation().zipCode
            DbUtil.getDataByZip(zipCode: self.zip, result: { incidents in
                self.incidentList.removeAll()
                self.incidentList.append(contentsOf: incidents)
//                var incidentList = incidentList
                self.incidentList = self.incidentList.sorted(by: {
                    $0.dateTime.compare($1.dateTime) == .orderedDescending
                })
                self.tableView.reloadData()
            });
    }
    
    func loadDataByZip(zip: String, value: @escaping (([SCIncident]) -> Void)) {
        self.incidentList.removeAll()
        let iList = IncidentList.shared.getIncidentByZip(zip: zip)
        if (iList != nil) {
            value(iList!)
        } else {
            self.zip = zip
            DbUtil.getDataByZip(zipCode: self.zip, result: { incidents in
                value(incidents)
            });
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredIncidents.count
        }
        return self.incidentList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentCell", for: indexPath) as! IncidentTableViewCell
        let incident: SCIncident
        if (isFiltering()) {
            incident = self.filteredIncidents[indexPath.row]
        } else {
            incident = self.incidentList[indexPath.row]
            self.changeFilterDisplay(false)
        }
        cell.incidentCodeGroup?.text = incident.offenceCodeGroup
        cell.incidentDesc?.text = incident.offenceDescription
        cell.streetZip?.text = "\(incident.location.street) \(incident.location.zipCode)"
        if (incident.verified > 0) {
            cell.verified?.text = String(incident.verified)
        } else {
            cell.verified?.isHidden = true
        }
        cell.date?.text = incident.dateTime.toString(dateFormat: "MM/dd/yyyy HH:mm")
        
        var image1 = UIImage(named: "addIncident")
        cell.incidentImage.image = image1
        
//        let image = incident.images
//        cell.incidentImage.image = UIImage(named: image)
        
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? .white : UIColor(rgb: 0xF5F5F5)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isFiltering()) {
            self.selectedIncident = self.filteredIncidents[indexPath.row]
        } else {
            self.selectedIncident = self.incidentList[indexPath.row]
        }
        self.performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let dvc = segue.destination as! DetailIncidentViewController
            dvc.incident = self.selectedIncident!
        }
        
        if segue.identifier == "filterSegue" {
            let popoverViewController = segue.destination as! FilterPopupViewController
            popoverViewController.delegate = self
        }
        
        if segue.identifier == "mapSegue" {
            for i in incidentList {
//                if(i.status == "ACTIVE") {
                    let incidentMapViewController = segue.destination as! IncidentMapViewController
                    if (self.isFiltering() && self.filteredIncidents.count > 0) {
                        incidentMapViewController.incidentList = self.filteredIncidents
                    } else {
                        incidentMapViewController.incidentList = self.incidentList
                    }
//                }
//                else {
                    
//                }
            }
            
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func changeFilterDisplay(_ status: Bool) {
        if (status) {
            searchController.searchBar.setImage(UIImage(named: "filterClear"), for: .bookmark, state: .normal)
        } else {
            searchController.searchBar.setImage(UIImage(named: "filter"), for: .bookmark, state: .normal)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    // MARK: - methods related to searching
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return (searchController.isActive && !searchBarIsEmpty()) || displayFiltered
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredIncidents = incidentList.filter({( i : SCIncident) -> Bool in
            return i.offenceCodeGroup.contains(searchText)
        })
        
        tableView.reloadData()
    }
    
    func filterContentByFilter(filters: [String: String?], list: [SCIncident]) {
        var newList = list
        if (filters["Catagory"] != nil && filters["Catagory"] != "None") {
            newList = list.filter({( i : SCIncident) -> Bool in
                return i.offenceCodeGroup == filters["Catagory"]
            })
        }
        
        if (filters["Occurance"] != nil && filters["Occurance"] != "None") {
            if (filters["Occurance"] == "Recent") {
                let twoDaysAgo = Calendar.current.date(
                    byAdding: .day,
                    value: -2,
                    to: Date())
                newList = list.filter({( i : SCIncident) -> Bool in
                    return i.dateTime > twoDaysAgo!
                })
            }
            
            if (filters["Occurance"] == "Last 7 days") {
                let sevenDaysAgo = Calendar.current.date(
                    byAdding: .day,
                    value: -7,
                    to: Date())
                newList = list.filter({( i : SCIncident) -> Bool in
                    return i.dateTime > sevenDaysAgo!
                })
            }
            
            if (filters["Occurance"] == "Last Month") {
                let monthAgo = Calendar.current.date(
                    byAdding: .day,
                    value: -30,
                    to: Date())
                newList = list.filter({( i : SCIncident) -> Bool in
                    return i.dateTime > monthAgo!
                })
            }
        }
        
        if (filters["Status"] != nil && filters["Status"] != "All") {
            if (filters["Status"] == "Active") {
                newList = list.filter({( i : SCIncident) -> Bool in
                    return i.status == "ACTIVE"
                })
            }
            
            if (filters["Status"] == "Inactive") {
                newList = list.filter({( i : SCIncident) -> Bool in
                    return i.status == "IN_ACTIVE"
                })
            }
        }
        
        self.filteredIncidents = newList;
        self.displayFiltered = true
        tableView.reloadData()
        self.changeFilterDisplay(true)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if (displayFiltered) {
            displayFiltered = false
            tableView.reloadData()
        } else {
            self.performSegue(withIdentifier: "filterSegue", sender: nil)
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text! != "") {
            self.filterContentForSearchText(searchController.searchBar.text!)
        }
        if searchController.isActive {
            searchController.searchBar.showsBookmarkButton = false
        } else {
            searchController.searchBar.showsBookmarkButton = true
        }
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchTableViewController: FilterDelegate {
    
    func filterValueSelected(filters: [String: String?]) {
        if (filters["Zip"] != nil) {
            self.loadDataByZip(zip: filters["Zip"] as! String, value: { incidents in
                //displayFiltered = true;
                self.filterContentByFilter(filters: filters, list: incidents)
            })
        }
        self.filterContentByFilter(filters: filters, list: self.incidentList)
    }
}


