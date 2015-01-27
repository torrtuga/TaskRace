//
//  DaysViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class DaysViewController: UITableViewController {
    
    var days: [Day]!
    
    override func viewDidLoad() {
        updateData()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let lastDay = days.first {
            if lastDay.date < Date(date: NSDate()) {
                updateData()
                tableView.reloadData()
            }
        }
    }
    
    private func updateData() {
        days = UserDataController.sharedController().allDays().reverse()
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = days[indexPath.row].date.string
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let day = days[indexPath.row]
        performSegueWithIdentifier("DaySegue", sender: day)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? DayViewController {
            destination.day = sender as Day
        }
    }
    
}
