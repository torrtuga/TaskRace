//
//  OrderItemsViewController.swift
//  TaskRace
//
//  Created by Heather Shelley on 4/21/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation

import UIKit

class OrderItemsViewController: UITableViewController {
    
    var items: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = UserDataController.sharedController().regularTemplateLists().flatMap({ $0.items })
        if UserDataController.sharedController().useGlobalOrdering() {
            items.sort { $0.position <= $1.position }
        }
        setEditing(true, animated: false)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) -> Void {
        for list in UserDataController.sharedController().regularTemplateLists() {
            UserDataController.sharedController().addOrUpdateList(list)
        }
        UserDataController.sharedController().setUseGlobalOrdering(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) -> Void {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movedItem = items.removeAtIndex(sourceIndexPath.row)
        items.insert(movedItem, atIndex: destinationIndexPath.row)
        items.each(){ (i, t) -> Void in
            // Space them out so adding to templates doesn't result in ambiguous positions
            t.position = i * 100
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            let item = items[indexPath.row]
            cell.textLabel?.text = item.name
            var detailText = ""
            if item.minutes > 0 {
                detailText += "\(item.minutes)min,"
            }
            detailText += "\(item.points)pts"
            cell.detailTextLabel?.text = detailText
            return cell
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
    
}