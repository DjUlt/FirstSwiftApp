//
//  ContactsTableViewController.swift
//  FirstApp
//
//  Created by user on 29.10.2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //MARK: Variables
    private var contactsArray = [Section]() {
        didSet {
            dataChanged = true
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var filteredContacts: [Section] = []
    
    private var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    private var dataChanged = false
    
    //MARK: Structs
    struct Section {
        var sectionName : Character
        var sectionObjects : [Contact]
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        loadInitialData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteDataOnNotification(notification:)), name: .didDeleteData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeDataOnNotification), name: Notification.Name("didChangeData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addDataOnNotification(notification:)), name: Notification.Name("didAddData"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if navigationController?.topViewController == self {
            if dataChanged {
                fixData()
                sortData()
                tableView.reloadData()
                dataChanged = false
            }
        }
    }
    
    // MARK: - Table view data source
    
     override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return getKeys()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(contactsArray[section].sectionName)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contactsArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredContacts[section].sectionObjects.count
        }
        return contactsArray[section].sectionObjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as? ContactTableViewCell else { fatalError("cell is not ContactTableViewCell") }

        let celldata: Contact
        if isFiltering {
          celldata = filteredContacts[indexPath.section].sectionObjects[indexPath.row]
        } else {
          celldata = contactsArray[indexPath.section].sectionObjects[indexPath.row]
        }
        
        if celldata.name.isEmpty && celldata.secondName.isEmpty {
            cell.nameLabel.text = "No name"
        } else {
            if celldata.name.isEmpty && !celldata.secondName.isEmpty {
                cell.nameLabel.text = celldata.secondName
            } else {
                cell.nameLabel.text = celldata.name + " " + celldata.secondName
            }
        }
        

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactDataViewController" {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            let secondVC: ContactDataViewController = segue.destination as! ContactDataViewController
            let contact: Contact
            if isFiltering {
                contact = filteredContacts[indexPath.section].sectionObjects[indexPath.row]
            } else {
              contact = contactsArray[indexPath.section].sectionObjects[indexPath.row]
            }
            secondVC.gottenContactData = contact
        }
    }
    
    //MARK: Internal Functions
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    //MARK: Private functions
    private func loadInitialData(){
        addContact(Contact(name: "Alex", secondName: "Europhimoff", phoneNumber: "+38099999999", email: "test@mail.com", image: UIImage(systemName: "person")!))
        addContact(Contact(name: "Ale", secondName: "Europh", phoneNumber: "+38000000000", email: "nottest@mail.com", image: UIImage(systemName: "person")!))
        addContact(Contact(name: "Borya", secondName: "Stasetskii", phoneNumber: "+38000000011", email: "defenetlynottest@mail.com", image: UIImage(systemName: "person")!))
        
        sortData()
        tableView.reloadData()
    }
    
    private func getKeys() -> [String] {
        var returnArray: [String] = []
        for i in 0 ..< contactsArray.count {
            returnArray.append(String(contactsArray[i].sectionName))
        }
        return returnArray.sorted()
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        var temp: [Section] = []
        for i in 0 ..< contactsArray.count {
            var tempSection: Section = Section(sectionName: "N", sectionObjects: [])
            for j in 0 ..< contactsArray[i].sectionObjects.count {
                if ( contactsArray[i].sectionObjects[j].name.lowercased() + " " + contactsArray[i].sectionObjects[j].secondName.lowercased() ).contains(searchText.lowercased()) {
                    tempSection.sectionObjects.append(contactsArray[i].sectionObjects[j])
                }
            }
                tempSection.sectionName = tempSection.sectionObjects.first?.name.uppercased().first ?? tempSection.sectionObjects.first?.name.uppercased().first ?? "N"
                temp.append(tempSection)
        }
        
        filteredContacts = temp
        
        tableView.reloadData()
    }
    
    private func checkOnValid(contact: Contact) -> (Bool, Int, Int) {
        for i in 0 ..< contactsArray.count {
            if (contact.name.uppercased().first ?? contact.secondName.uppercased().first ?? "N") == contactsArray[i].sectionName {
                for j in 0 ..< contactsArray[i].sectionObjects.count {
                    if contact == contactsArray[i].sectionObjects[j] {
                        return (true, i, j)
                    }
                }
            }
        }
        
        return (false, -1, -1)
    }
    
    @objc private func addDataOnNotification(notification: Notification) {
        guard let contactToAdd = notification.userInfo?["contact"] as? Contact else { return }
        addContact(contactToAdd)
        fixData()
        sortData()
        tableView.reloadData()
        dataChanged = false
    }
    
    @objc private func changeDataOnNotification() {
        fixData()
        dataChanged = true
    }
    
    @objc private func deleteDataOnNotification(notification: Notification) {
        guard let contactToDelete = notification.userInfo?["contact"] as? Contact else { return }
        deleteData(contact: contactToDelete)
    }
    
    private func deleteData(contact: Contact) {
        let (checked, i, j) = checkOnValid(contact: contact)
        if checked {
            contactsArray[i].sectionObjects.remove(at: j)
            
            if contactsArray[i].sectionObjects.count == 0 {
                contactsArray.remove(at: i)
            }
        }
    }
    
    private func fixData() {
        var temp: Contact
        for i in (0 ..< contactsArray.count).reversed() {
            for j in (0 ..< contactsArray[i].sectionObjects.count).reversed() {
                if (contactsArray[i].sectionObjects[j].name.uppercased().first ?? contactsArray[i].sectionObjects[j].secondName.uppercased().first ?? "N") != contactsArray[i].sectionName {
                    temp = contactsArray[i].sectionObjects[j]
                    contactsArray[i].sectionObjects.remove(at: j)
                    addContact(temp)
                }
            }
            
            if contactsArray[i].sectionObjects.count == 0 {
                contactsArray.remove(at: i)
            }
        }
    }
    
    private func sortData() {
        contactsArray.sort { $0.sectionName < $1.sectionName }
        for i in 0 ..< contactsArray.count {
            contactsArray[i].sectionObjects.sort { $0.name < $1.name }
        }
    }
    
    private func addContact(_ contact: Contact) {
        if !getKeys().contains(String(contact.name.uppercased().first ?? contact.secondName.uppercased().first ?? "N")) {
            contactsArray.append( Section( sectionName: contact.name.uppercased().first ?? contact.secondName.uppercased().first ?? "N", sectionObjects: []) )
        }
        
        for i in 0 ..< contactsArray.count {
            if contactsArray[i].sectionName == contact.name.uppercased().first ?? contact.secondName.uppercased().first ?? "N" {
                contactsArray[i].sectionObjects.append(contact)
            }
        }
    }
    
}

extension NSNotification.Name {
    static let didDeleteData = NSNotification.Name("didDeleteData")
}
