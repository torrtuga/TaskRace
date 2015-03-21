//
//  HistoryViewController.swift
//  Todo
//
//  Created by Heather Shelley on 1/1/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation

import UIKit

class HistoryViewController: UITableViewController {
    
    var sections: [(title: String, items: [HistoryItem])] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        sections = UserDataController.sharedController().historyItems().partitionBy({
            Date(date: $0.dateCompleted)
        }).map() { dayArray in
            (Date(date: dayArray[0].dateCompleted).string, dayArray)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.name + (item.numberCompleted > 1 ? " (\(item.numberCompleted))" : "")
        cell.detailTextLabel?.text = "\(item.points)pts"
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let totalPoints = sections[section].items.map { $0.points }.reduce(0, +)
        return sections[section].title + " (\(totalPoints) points)"
    }
}
