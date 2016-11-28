//
//  HistoryViewController.swift
//  Todo
//
//  Created by Heather Shelley on 1/1/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import UIKit
import Swiftification

class HistoryViewController: UITableViewController {
    
    let dayFormatter = DateFormatter()
    var sections: [(title: String, items: [HistoryItem])] = []
    
    override func viewDidLoad() {
        dayFormatter.dateFormat = "EEE, MMM d"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sections = UserDataController.sharedController().historyItems().sectionBy{ self.dayFormatter.string(from: $0.dateCompleted) }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.name + (item.numberCompleted > 1 ? " (\(item.numberCompleted))" : "")
        cell.detailTextLabel?.text = "\(item.points)pts"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let totalPoints = sections[section].items.map { $0.points }.reduce(0, +)
        return sections[section].title + " (\(totalPoints) points)"
    }
}
