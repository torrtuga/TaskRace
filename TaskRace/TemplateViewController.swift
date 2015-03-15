//
//  TemplateViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/8/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class TemplateViewController: UITableViewController {
    
    var list: List!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems?.append(editButtonItem())
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
        return indexPath.section > 1
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 1
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
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 7
        } else {
            return list.items.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "Anytime"
            let anytimeSwitch = UISwitch()
            anytimeSwitch.on = template.anytime
            anytimeSwitch.addTarget(self, action: "switchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            cell.accessoryView = anytimeSwitch
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath) as UITableViewCell
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = TemplateDays.Sunday.stringValue
                cell.tag = Int(TemplateDays.Sunday.rawValue)
            case 1:
                cell.textLabel?.text = TemplateDays.Monday.stringValue
                cell.tag = Int(TemplateDays.Monday.rawValue)
            case 2:
                cell.textLabel?.text = TemplateDays.Tuesday.stringValue
                cell.tag = Int(TemplateDays.Tuesday.rawValue)
            case 3:
                cell.textLabel?.text = TemplateDays.Wednesday.stringValue
                cell.tag = Int(TemplateDays.Wednesday.rawValue)
            case 4:
                cell.textLabel?.text = TemplateDays.Thursday.stringValue
                cell.tag = Int(TemplateDays.Thursday.rawValue)
            case 5:
                cell.textLabel?.text = TemplateDays.Friday.stringValue
                cell.tag = Int(TemplateDays.Friday.rawValue)
            case 6:
                cell.textLabel?.text = TemplateDays.Saturday.stringValue
                cell.tag = Int(TemplateDays.Saturday.rawValue)
            default:
                cell.textLabel?.text = "Not handled"
            }
            if template!.templateDays.rawValue & UInt(cell.tag) != 0 {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TodoCell", forIndexPath: indexPath) as UITableViewCell
            let item = list.items[indexPath.row]
            cell.textLabel?.text = item.name
            var detailText = ""
            if item.minutes > 0 {
                detailText += "\(item.minutes)min,"
            }
            detailText += "\(item.points)pts"
            cell.detailTextLabel?.text = detailText
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
    }
    
    func switchValueChanged(sender: UISwitch) {
        template.anytime = sender.on
        UserDataController.sharedController().addOrUpdateTemplate(template)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                template.templateDays = template.templateDays ^ TemplateDays(UInt(cell.tag))
            } else {
                cell.accessoryType = .Checkmark
                template.templateDays = template.templateDays | TemplateDays(UInt(cell.tag))
            }
            UserDataController.sharedController().addOrUpdateTemplate(template)
        } else if indexPath.section == 2 {
            let item = list.items[indexPath.row]
            performSegueWithIdentifier("EditItemSegue", sender: item)
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
                editViewController.saveFunction = { name, points, minutes, repeats, repeatCount in
                    item.name = name
                    item.repeats = repeats
                    if let points = points {
                        item.points = points
                    }
                    
                    if let minutes = minutes {
                        item.minutes = minutes
                    }
                    
                    if let repeatCount = repeatCount {
                        item.repeatCount = repeatCount
                    }
                    
                    UserDataController.sharedController().addOrUpdateList(self.list)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
