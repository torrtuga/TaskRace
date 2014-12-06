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
        navigationItem.leftBarButtonItem = editButtonItem()
        templates = UserDataController.sharedController().allTemplates()
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
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
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movedTemplate = templates.removeAtIndex(sourceIndexPath.row)
        templates.insert(movedTemplate, atIndex: destinationIndexPath.row)
        templates.each(){ (i, t) -> Void in
            t.position = i
        }
        UserDataController.sharedController().updateTemplates(templates)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = templates[indexPath.row].name
        cell.detailTextLabel?.text = daysStringFromTemplateDays(templates[indexPath.row].templateDays)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let template = templates[indexPath.row]
        if editing {
            let alertController = UIAlertController(title: "Edit Title", message: nil, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler() { textField in
                textField.text = template.name
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                let textField = alertController.textFields!.first as UITextField
                template.name = textField.text
                UserDataController.sharedController().addOrUpdateTemplate(template)
                self.tableView.reloadData()
            }))
            self .presentViewController(alertController, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("TemplateDetailSegue", sender: template)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO: handle deletion
            UserDataController.sharedController().removeTemplate(templates[indexPath.row])
            templates.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? TemplateViewController {
            destination.template = sender as Template
        }
    }
    
}
