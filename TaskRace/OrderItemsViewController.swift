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
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) -> Void {
        for list in UserDataController.sharedController().regularTemplateLists() {
            UserDataController.sharedController().addOrUpdateList(list)
        }
        UserDataController.sharedController().setUseGlobalOrdering(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) -> Void {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = items.remove(at: sourceIndexPath.row)
        items.insert(movedItem, at: destinationIndexPath.row)
        for (i, t) in items.enumerated() {
            // Space them out so adding to templates doesn't result in ambiguous positions
            t.position = i * 100
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return "Template Days"
        } else {
            return "Items"
        }
    }
    
}
