//
//  DayViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class DayViewController: UITableViewController {
    
    var list: List = List()
    var anytimeItems: [TodoItem] = []
    var day: Day!
    
    override func viewDidLoad() {
        if day == nil {
            day = UserDataController.sharedController().dayForToday()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    private func updateData() {
        if let day = day {
            navigationItem.title = day.date.string
            if let listID = day.listID {
                list = UserDataController.sharedController().listWithID(listID)
            } else {
                list = List()
                day.listID = list.id
                UserDataController.sharedController().addOrUpdateDay(day)
            }
            
            UserDataController.sharedController().updateListFromTemplates(list: list, forDate: day.date)
            anytimeItems = UserDataController.sharedController().anytimeTodoItemsForDate(day.date)
            tableView.reloadData()
        }
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let position = list.items.count
        let item = TodoItem(name: "New Item", position: position)
        list.items.append(item)
        UserDataController.sharedController().addOrUpdateList(list)
        let indexPath = NSIndexPath(forRow: position, inSection: 2)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movedItem = list.items.removeAtIndex(sourceIndexPath.row)
        list.items.insert(movedItem, atIndex: destinationIndexPath.row)
        list.items.each(){ (i, t) -> Void in
            t.position = i
        }
        UserDataController.sharedController().addOrUpdateList(list)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return list.items.count
        } else if section == 1 {
            return anytimeItems.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = indexPath.section == 0 ? list.items[indexPath.row] : anytimeItems[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = item.name
        var detailText = ""
        if item.minutes > 0 {
            detailText += "\(item.minutes)min,"
        }
        detailText += "\(item.points)pts"
        cell.detailTextLabel?.text = detailText
        if item.completed {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = indexPath.section == 0 ? list.items[indexPath.row] : anytimeItems[indexPath.row]
        if item.repeats {
            let alertController = UIAlertController(title: "Completed", message: "How many of the specified task were completed?", preferredStyle: UIAlertControllerStyle.Alert)
            let doneAction = UIAlertAction(title: "Done", style: .Default) { _ in
                let numberTextField = alertController.textFields![0] as UITextField
                if let numberComplete = numberTextField.text.toInt() {
                    let pointsToAdd = numberComplete * item.points
                    UserDataController.sharedController().addPointsToStore(pointsToAdd)
                    let successAlert = UIAlertController(title: "Success", message: "Successfully added \(pointsToAdd) points to store.", preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { _ in }
                    successAlert.addAction(cancelAction)
                    self.presentViewController(successAlert, animated: true, completion: nil)
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
            if item.completed {
                cell.accessoryType = .None
                item.completed = false
                UserDataController.sharedController().addPointsToStore(-item.points)
            } else {
                cell.accessoryType = .Checkmark
                item.completed = true
                UserDataController.sharedController().addPointsToStore(item.points)
            }
        }
        
        if indexPath.section == 0 {
            UserDataController.sharedController().addOrUpdateList(list)
        } else {
            UserDataController.sharedController().updateAnytimeListsForDate(day.date)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 && anytimeItems.count > 0 {
            return "Anytime"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var items = list.items
            list.items.removeAtIndex(indexPath.row)
            UserDataController.sharedController().addOrUpdateList(list)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let item = sender as? TodoItem {
            if let editViewController = segue.destinationViewController as? EditTodoItemViewController {
                editViewController.item = item
                editViewController.saveFunction = { name, points, minutes, repeats in
                    item.name = name
                    item.repeats = repeats
                    if let points = points {
                        item.points = points
                    }
                    
                    if let minutes = minutes {
                        item.minutes = minutes
                    }
                    UserDataController.sharedController().addOrUpdateList(self.list)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
