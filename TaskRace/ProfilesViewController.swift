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
            let textField = alertController.textFields!.first as! UITextField
            let profile = textField.text
            
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
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
        UserDataController.currentProfile = profiles[indexPath.row]
        tableView.reloadData()
    }

}
