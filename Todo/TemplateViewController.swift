//
//  TemplateViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/8/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class TemplateViewController: UITableViewController {
    
    var list: List = List()
    var template: Template! {
        didSet {
            if let template = template {
                navigationItem.title = template.name
                if let listID = template.listID {
                    list = UserDataController.sharedController().listWithID(listID)
                } else {
                    list = List()
                    template.listID = list.id
                    UserDataController.sharedController().addOrUpdateList(list)
                    UserDataController.sharedController().addOrUpdateTemplate(template)
                }
                
            }
        }
    }

    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let position = list.items.count
        let item = TodoItem(name: "New Item", position: position)
        list.items.append(item)
        UserDataController.sharedController().addOrUpdateList(list)
        let indexPath = NSIndexPath(forRow: position, inSection: 1)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 0
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 0
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
            return 7
        } else {
            return list.items.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath) as UITableViewCell
            switch indexPath.row {
            case 0:
                cell.textLabel.text = TemplateDays.Sunday.stringValue
                cell.tag = Int(TemplateDays.Sunday.rawValue)
            case 1:
                cell.textLabel.text = TemplateDays.Monday.stringValue
                cell.tag = Int(TemplateDays.Monday.rawValue)
            case 2:
                cell.textLabel.text = TemplateDays.Tuesday.stringValue
                cell.tag = Int(TemplateDays.Tuesday.rawValue)
            case 3:
                cell.textLabel.text = TemplateDays.Wednesday.stringValue
                cell.tag = Int(TemplateDays.Wednesday.rawValue)
            case 4:
                cell.textLabel.text = TemplateDays.Thursday.stringValue
                cell.tag = Int(TemplateDays.Thursday.rawValue)
            case 5:
                cell.textLabel.text = TemplateDays.Friday.stringValue
                cell.tag = Int(TemplateDays.Friday.rawValue)
            case 6:
                cell.textLabel.text = TemplateDays.Saturday.stringValue
                cell.tag = Int(TemplateDays.Saturday.rawValue)
            default:
                cell.textLabel.text = "Not handled"
            }
            if template!.templateDays.rawValue & UInt(cell.tag) != 0 {
                cell.accessoryType = .Checkmark
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TodoCell", forIndexPath: indexPath) as TodoItemCell
            let item = list.items[indexPath.row]
            cell.titleLabel.text = item.name
            cell.timeLabel.text = "\(item.minutes) min"
            cell.pointsLabel.text = "\(item.points) pts"
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                template!.templateDays = TemplateDays(template!.templateDays.rawValue ^ UInt(cell.tag))
            } else {
                cell.accessoryType = .Checkmark
                template!.templateDays = TemplateDays(template!.templateDays.rawValue | UInt(cell.tag))
            }
            UserDataController.sharedController().addOrUpdateTemplate(template)
        } else {
            let item = list.items[indexPath.row]
            performSegueWithIdentifier("EditItemSegue", sender: item)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Template Days"
        } else {
            return "Items"
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO: handle deletion
            var items = list.items
            list.items.removeAtIndex(indexPath.row)
            UserDataController.sharedController().addOrUpdateList(list)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let item = sender as? TodoItem {
            if let editViewController = segue.destinationViewController as? EditTodoItemViewController {
                editViewController.item = item
                editViewController.saveFunction = { name, points, minutes in
                    item.name = name
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
