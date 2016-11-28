//
//  StoreViewController.swift
//  Todo
//
//  Created by Heather Shelley on 12/6/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class StoreViewController: UITableViewController {
    
    var items: [StoreItem]!
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTitle()
        items = UserDataController.sharedController().storeItems()
        tableView.reloadData()
    }
    
    func updateTitle() {
        let storePoints = UserDataController.sharedController().storePoints()
        navigationItem.title = "\(storePoints) Points"
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) -> Void {
        let position = items.count
        let item = StoreItem(name: "New Item", position: position)
        items.append(item)
        UserDataController.sharedController().addOrUpdateStoreItem(item)
        let indexPath = IndexPath(row: position, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = items.remove(at: sourceIndexPath.row)
        items.insert(movedItem, at: destinationIndexPath.row)
        for (i, t) in items.enumerated() {
            t.position = i
        }
        UserDataController.sharedController().updateStoreItems(items)
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
        cell.detailTextLabel?.text = "\(item.points)pts"
        if item.purchased {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if isEditing {
            if !item.purchased {
               performSegue(withIdentifier: "EditItemSegue", sender: item)
            } else {
                let alertController = UIAlertController(title: "Cannot Edit", message: "You cannot edit a purchased item.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        } else {
            if item.repeats {
                let alertController = UIAlertController(title: "Amount to Buy", message: "How many of the specified item would you like to purchase?", preferredStyle: UIAlertControllerStyle.alert)
                let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                    let numberTextField = alertController.textFields![0] 
                    if let numberComplete = Int(numberTextField.text!) {
                        UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: numberComplete)
                        self.updateTitle()
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                alertController.addTextField() { textField in
                    textField.keyboardType = .numberPad
                }
                alertController.addAction(cancelAction)
                alertController.addAction(doneAction)
                present(alertController, animated: true, completion: nil)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                let cell = tableView.cellForRow(at: indexPath)!
                if item.purchased {
                    cell.accessoryType = .none
                    item.purchased = false
                    UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: -1)
                } else {
                    cell.accessoryType = .checkmark
                    item.purchased = true
                    UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: 1)
                }
                updateTitle()
            }
        }
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items.remove(at: indexPath.row)
            UserDataController.sharedController().deleteStoreItem(item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let item = sender as? StoreItem {
            if let editViewController = segue.destination as? EditStoreItemViewController {
                editViewController.item = item
                editViewController.saveFunction = { name, points, repeats in
                    item.name = name
                    item.repeats = repeats
                    if let points = points {
                        item.points = points
                    }
                    
                    UserDataController.sharedController().addOrUpdateStoreItem(item)
                    self.tableView.reloadRows(at: [IndexPath(row:item.position, section: 0)], with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }
}
