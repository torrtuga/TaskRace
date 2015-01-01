//
//  StoreViewController.swift
//  Todo
//
//  Created by Heather Shelley on 12/6/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class StoreViewController: UITableViewController {
    
    var items: [StoreItem]!
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem()
        items = UserDataController.sharedController().storeItems()
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(animated: Bool) {
        updateTitle()
    }
    
    func updateTitle() {
        let storePoints = UserDataController.sharedController().storePoints()
        navigationItem.title = "\(storePoints) Points"
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let position = items.count
        let item = StoreItem(name: "New Item", position: position)
        items.append(item)
        UserDataController.sharedController().addOrUpdateStoreItem(item)
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
        let movedItem = items.removeAtIndex(sourceIndexPath.row)
        items.insert(movedItem, atIndex: destinationIndexPath.row)
        items.each(){ (i, t) -> Void in
            t.position = i
        }
        UserDataController.sharedController().updateStoreItems(items)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.points)pts"
        if item.purchased {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        if editing {
            performSegueWithIdentifier("EditItemSegue", sender: item)
        } else {
            if item.repeats {
                let alertController = UIAlertController(title: "Amount to Buy", message: "How many of the specified item would you like to purchase?", preferredStyle: UIAlertControllerStyle.Alert)
                let doneAction = UIAlertAction(title: "Done", style: .Default) { _ in
                    let numberTextField = alertController.textFields![0] as UITextField
                    if let numberComplete = numberTextField.text.toInt() {
                        UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: numberComplete)
                        self.updateTitle()
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in }
                alertController.addTextFieldWithConfigurationHandler() { _ in }
                alertController.addAction(cancelAction)
                alertController.addAction(doneAction)
                presentViewController(alertController, animated: true, completion: nil)
            } else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                if item.purchased {
                    cell.accessoryType = .None
                    item.purchased = false
                    UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: -1)
                } else {
                    cell.accessoryType = .Checkmark
                    item.purchased = true
                    UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: 1)
                }
                updateTitle()
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return "Template Days"
        } else {
            return "Items"
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = items.removeAtIndex(indexPath.row)
            UserDataController.sharedController().deleteStoreItem(item)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let item = sender as? StoreItem {
            if let editViewController = segue.destinationViewController as? EditStoreItemViewController {
                editViewController.item = item
                editViewController.saveFunction = { name, points, repeats in
                    item.name = name
                    item.repeats = repeats
                    if let points = points {
                        item.points = points
                    }
                    
                    UserDataController.sharedController().addOrUpdateStoreItem(item)
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:item.position, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }
    }
}
