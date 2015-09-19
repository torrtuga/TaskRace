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
        navigationItem.rightBarButtonItems?.append(editButtonItem())
        tableView.allowsSelectionDuringEditing = true
    }
    
    private func updateData() {
        profiles = ["Default"] + UserDataController.allProfiles()
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let alertController = UIAlertController(title: "Profile Name", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler() { textField in
            textField.text = "New Profile"
            textField.autocapitalizationType = .Words
            textField.clearButtonMode = UITextFieldViewMode.Always
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
            let textField = alertController.textFields!.first!
            let profile = textField.text!
            
            if self.profiles.map({ $0.lowercaseString }).contains(profile.lowercaseString) {
                let alertController = UIAlertController(title: "Cannot Add Profile", message: "That name is already taken. Please choose a unique name for a new profile.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let position = self.profiles.count
                self.profiles.append(profile)
                UserDataController.addProfile(profile)
                let indexPath = NSIndexPath(forRow: position, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }))
        self .presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row > 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete && profiles.count > 1 {
            let profile = profiles[indexPath.row]
            profiles.removeAtIndex(profiles.indexOf(profile)!)
            UserDataController.removeProfile(profile)
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        let profile = profiles[indexPath.row]
        cell.textLabel?.text = profile
        if UserDataController.currentProfile == profile {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profile = profiles[indexPath.row]
        if editing && indexPath.row > 0 {
            let alertController = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler() { textField in
                textField.text = profile
                textField.autocapitalizationType = .Words
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                let textField = alertController.textFields!.first!
                let newName = textField.text!
                UserDataController.renameProfile(profile, toProfile: newName)
                self.updateData()
                self.editing = false
                self.tableView.reloadData()
            }))
            self .presentViewController(alertController, animated: true, completion: nil)
        } else {
            UserDataController.currentProfile = profiles[indexPath.row]
            tableView.reloadData()
        }
    }

}
