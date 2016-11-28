//
//  SettingsViewController.swift
//  TaskRace
//
//  Created by Heather Shelley on 3/26/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var profiles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profiles = ["Default"] + UserDataController.allProfiles()
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        tableView.allowsSelectionDuringEditing = true
    }
    
    fileprivate func updateData() {
        profiles = ["Default"] + UserDataController.allProfiles()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) -> Void {
        let alertController = UIAlertController(title: "Profile Name", message: nil, preferredStyle: .alert)
        alertController.addTextField() { textField in
            textField.text = "New Profile"
            textField.autocapitalizationType = .words
            textField.clearButtonMode = UITextFieldViewMode.always
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
            let textField = alertController.textFields!.first!
            let profile = textField.text!
            
            if self.profiles.map({ $0.lowercased() }).contains(profile.lowercased()) {
                let alertController = UIAlertController(title: "Cannot Add Profile", message: "That name is already taken. Please choose a unique name for a new profile.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                let position = self.profiles.count
                self.profiles.append(profile)
                UserDataController.addProfile(profile)
                let indexPath = IndexPath(row: position, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }))
        self .present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && profiles.count > 1 {
            let profile = profiles[indexPath.row]
            profiles.remove(at: profiles.index(of: profile)!)
            UserDataController.removeProfile(profile)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        let profile = profiles[indexPath.row]
        cell.textLabel?.text = profile
        if UserDataController.currentProfile == profile {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = profiles[indexPath.row]
        if isEditing && indexPath.row > 0 {
            let alertController = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
            alertController.addTextField() { textField in
                textField.text = profile
                textField.autocapitalizationType = .words
                textField.clearButtonMode = UITextFieldViewMode.whileEditing
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
                let textField = alertController.textFields!.first!
                let newName = textField.text!
                UserDataController.renameProfile(profile, toProfile: newName)
                self.updateData()
                self.isEditing = false
                self.tableView.reloadData()
            }))
            self .present(alertController, animated: true, completion: nil)
        } else {
            UserDataController.currentProfile = profiles[indexPath.row]
            tableView.reloadData()
        }
    }

}
