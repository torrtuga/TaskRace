//
//  TemplatesViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/6/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class TemplatesViewController: UITableViewController {
    
    var templates: [Template] = []
    
    override func viewDidLoad() {
        templates = UserDataController.sharedController().allTemplates()
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let position = templates.count
        let template = Template(name: "New Template", position: position)
        UserDataController.sharedController().addOrUpdateTemplate(template)
        templates.append(template)
        let indexPath = NSIndexPath(forRow: position, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel.text = templates[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO: handle deletion
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}
