//
//  DayViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class DayViewController: UITableViewController {
    
    var todayList: List = List()
    var anytimeSections: [(name: String, list: List)] = []
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
                todayList = UserDataController.sharedController().listWithID(listID)
            } else {
                todayList = List()
                day.listID = todayList.id
                UserDataController.sharedController().addOrUpdateDay(day)
            }
            
            UserDataController.sharedController().updateListFromTemplates(list: todayList, forDate: day.date)
            anytimeSections = UserDataController.sharedController().anytimeListsForDate(day.date).filter() { $0.list.items.count > 0 }
            tableView.reloadData()
        }
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let position = todayList.items.count
        let item = TodoItem(name: "New Item", position: position)
        todayList.items.append(item)
        UserDataController.sharedController().addOrUpdateList(todayList)
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
        let movedItem = todayList.items.removeAtIndex(sourceIndexPath.row)
        todayList.items.insert(movedItem, atIndex: destinationIndexPath.row)
        todayList.items.each(){ (i, t) -> Void in
            t.position = i
        }
        UserDataController.sharedController().addOrUpdateList(todayList)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return anytimeSections.count + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todayList.items.count
        } else {
            return anytimeSections[section - 1].list.items.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = itemAtIndexPath(indexPath)
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
        let item = itemAtIndexPath(indexPath)
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
            alertController.addTextFieldWithConfigurationHandler() { textField in
                textField.keyboardType = .NumberPad
            }
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
            UserDataController.sharedController().addOrUpdateList(todayList)
        } else {
            UserDataController.sharedController().addOrUpdateList(anytimeSections[indexPath.section - 1].list)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Today"
        } else {
            return "\(anytimeSections[section - 1].name) - Anytime"
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var items = todayList.items
            todayList.items.removeAtIndex(indexPath.row)
            UserDataController.sharedController().addOrUpdateList(todayList)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    private func itemAtIndexPath(indexPath: NSIndexPath) -> TodoItem {
        return indexPath.section == 0 ? todayList.items[indexPath.row] : anytimeSections[indexPath.section - 1].list.items[indexPath.row];
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
                    UserDataController.sharedController().addOrUpdateList(self.todayList)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
