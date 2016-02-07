//
//  DayViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

enum DayViewControllerRegularSection: Int {
    case Info
    case PastDue
    case Today
    case Count
}

class DayViewController: UITableViewController {
    
    let timeFormatter = NSDateFormatter()
    let dayFormatter = NSDateFormatter()
    
    var todayList = List()
    var pastDueItems = [(item: TodoItem, listID: String)]()
    var anytimeSections: [(name: String, list: List)] = []
    var day: Day?
    var isNewDay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems?.append(editButtonItem())
        
        timeFormatter.AMSymbol = "am"
        timeFormatter.PMSymbol = "pm"
        timeFormatter.dateFormat = "h:mma"
        
        dayFormatter.dateFormat = "EEE, MMM d"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "significantTimeChange:", name: UIApplicationSignificantTimeChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileChanged:", name: ProfileChangedNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func updateData() {
        if let day = day {
            navigationItem.title = dayFormatter.stringFromDate(day.date.date)
            todayList = UserDataController.sharedController().listWithID(day.listID)
            UserDataController.sharedController().updateDayListFromTemplates(list: todayList, forDate: day.date)
            pastDueItems = UserDataController.sharedController().pastDueItems()
            anytimeSections = UserDataController.sharedController().anytimeListsForDate(day.date).filter() { $0.list.items.count > 0 }
            tableView.reloadData()
        } else {
            day = UserDataController.sharedController().dayForDate(Date(date: NSDate()))
        }
    }
    
    @IBAction func addPressed(sender: UIBarButtonItem) -> Void {
        let position = (todayList.items.last?.position ?? (todayList.items.count - 1)) + 1
        let item = TodoItem(name: "New Item", position: position)
        todayList.items.append(item)
        UserDataController.sharedController().addOrUpdateList(todayList)
        let indexPath = NSIndexPath(forRow: position, inSection: DayViewControllerRegularSection.Today.rawValue)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == DayViewControllerRegularSection.Today.rawValue
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == DayViewControllerRegularSection.Today.rawValue
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movedItem = todayList.items.removeAtIndex(sourceIndexPath.row)
        todayList.items.insert(movedItem, atIndex: destinationIndexPath.row)
        for (i, t) in todayList.items.enumerate() {
            t.position = i
        }
        UserDataController.sharedController().addOrUpdateList(todayList)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DayViewControllerRegularSection.Count.rawValue + anytimeSections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < DayViewControllerRegularSection.Count.rawValue {
            switch DayViewControllerRegularSection(rawValue: section) ?? .Count {
            case .Info:
                return 1
            case .PastDue:
                return pastDueItems.count
            case .Today:
                return todayList.items.count
            case .Count:
                return 0
            }
        } else {
            return anytimeSections[section - DayViewControllerRegularSection.Count.rawValue].list.items.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell") as! DayInfoCell
            let (completedPoints, totalPoints, remainingTime, totalTime) = todayList.items.reduce((0, 0, 0, 0)) { (current: (completedPoints: Int, totalPoints: Int, remainingTime: Int, totalTime: Int), item) in
                let newCompletedPoints = current.completedPoints + {
                    if item.repeats {
                        return item.points * item.numberCompleted
                    } else {
                        return item.completed ? item.points : 0
                    }
                }()
                
                let newTotalPoints = current.totalPoints + (item.points * (item.repeatCount > 0 ? item.repeatCount : 1))
                
                let newRemainingTime = current.remainingTime + {
                    if item.repeats {
                        return item.minutes * max(0, item.repeatCount - item.numberCompleted)
                    } else {
                        return item.completed ? 0 : item.minutes
                    }
                }()
                
                let newTotalTime = current.totalTime + (item.minutes * (item.repeatCount > 0 ? item.repeatCount : 1))
                
                return (newCompletedPoints, newTotalPoints, newRemainingTime, newTotalTime)
            }
            cell.pointsLabel.text = "\(completedPoints)/\(totalPoints)"
            
            let (totalTimeHours, totalTimeMinutes) = quotientAndRemainder(totalTime, divisor: 60)
            cell.totalTimeLabel.text = String(format: "%d:%02d", totalTimeHours, totalTimeMinutes)
            
            let endTime = NSDate().dateByAddingTimeInterval(NSTimeInterval(remainingTime * 60))
            cell.endTimeLabel.text = timeFormatter.stringFromDate(endTime)
            
            return cell
        } else {
            guard let item = itemAtIndexPath(indexPath) else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            cell.textLabel?.text = (item.repeats && item.repeatCount > 0 ? "\(item.numberCompleted)/\(item.repeatCount) " : "") + item.name
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
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let item = itemAtIndexPath(indexPath) else { return }
        
        if editing {
            if !item.completed {
                performSegueWithIdentifier("EditItemSegue", sender: item)
            } else {
                let alertController = UIAlertController(title: "Cannot Edit", message: "You cannot edit a completed item.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            let updateFunc: () -> Void = {
                if let list = self.listForIndexPath(indexPath) {
                    UserDataController.sharedController().addOrUpdateList(list)
                }
                
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            }
            if item.repeats {
                let alertController = UIAlertController(title: "Completed", message: "How many of the specified task were completed?", preferredStyle: UIAlertControllerStyle.Alert)
                let doneAction = UIAlertAction(title: "Done", style: .Default) { _ in
                    let numberTextField = alertController.textFields![0] 
                    if let numberComplete = Int(numberTextField.text!) {
                        let pointsToAdd = numberComplete * item.points
                        item.numberCompleted += numberComplete
                        item.completed = item.repeatCount > 0 && item.numberCompleted >= item.repeatCount
                        UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: numberComplete)
                        updateFunc()
                        
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
                item.completed = !item.completed
                let numberCompleted = item.completed ? 1 : -1
                UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: numberCompleted)
                
                updateFunc()
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < DayViewControllerRegularSection.Count.rawValue {
            switch DayViewControllerRegularSection(rawValue: section) ?? .Count {
            case .Info:
                return nil
            case .PastDue:
                return pastDueItems.isEmpty ? nil : "Past Due"
            case .Today:
                return "Today"
            case .Count:
                return nil
            }
        } else {
            return "\(anytimeSections[section - 3].name) - Anytime"
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            todayList.items.removeAtIndex(indexPath.row)
            UserDataController.sharedController().addOrUpdateList(todayList)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    private func listForIndexPath(indexPath: NSIndexPath) -> List? {
        if indexPath.section < DayViewControllerRegularSection.Count.rawValue {
            switch DayViewControllerRegularSection(rawValue: indexPath.section) ?? .Count {
            case .Info:
                return nil
            case .PastDue:
                return UserDataController.sharedController().listWithID(pastDueItems[indexPath.row].listID)
            case .Today:
                return todayList
            case .Count:
                return nil
            }
        } else {
            return anytimeSections[indexPath.section - DayViewControllerRegularSection.Count.rawValue].list
        }
    }
    
    private func itemAtIndexPath(indexPath: NSIndexPath) -> TodoItem? {
        if indexPath.section < DayViewControllerRegularSection.Count.rawValue {
            switch DayViewControllerRegularSection(rawValue: indexPath.section) ?? .Count {
            case .Info:
                return nil
            case .PastDue:
                return pastDueItems[indexPath.row].item
            case .Today:
                return todayList.items[indexPath.row]
            case .Count:
                return nil
            }
        } else {
            return anytimeSections[indexPath.section - DayViewControllerRegularSection.Count.rawValue].list.items[indexPath.row]
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let item = sender as? TodoItem {
            if let editViewController = segue.destinationViewController as? EditTodoItemTableViewController {
                editViewController.item = item
                editViewController.anytime = false
                editViewController.saveFunction = {
                    UserDataController.sharedController().addOrUpdateList(self.todayList)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func quotientAndRemainder(dividend: Int, divisor: Int) -> (Int, Int) {
        return (dividend / divisor, dividend % divisor)
    }
    
    func significantTimeChange(_: NSNotification) {
        isNewDay = true
    }
    
    func applicationDidBecomeActive(_: NSNotification) {
        if isNewDay {
            isNewDay = false
            day = UserDataController.sharedController().dayForDate(Date(date: NSDate()))
            updateData()
        }
    }
    
    func profileChanged(_: NSNotification) {
        day = nil
        updateData()
    }
    
}
