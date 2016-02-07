//
//  EditTodoItemViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/11/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

enum EditTodoItemSection: Int {
    case Info
    case Repeat
    case Due
    case Count
}

class EditTodoItemTableViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointsTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var repeatsSwitch: UISwitch!
    @IBOutlet weak var dueSwitch: UISwitch!
    @IBOutlet weak var repeatCountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var item: TodoItem?
    var anytime = false
    var saveFunction: () -> Void = { print("Save function not implemented") }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        if let item = item {
            nameTextField.text = item.name
            nameTextField.autocapitalizationType = .Sentences
            pointsTextField.text = "\(item.points)"
            minutesTextField.text = "\(item.minutes)"
            repeatsSwitch.on = item.repeats
            repeatCountTextField.text = "\(item.repeatCount)"
            dueSwitch.on = item.dueDate != nil
            if let dueDate = item.dueDate {
                datePicker.date = dueDate.date
            }
            tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if anytime {
            return repeatsSwitch.on ? EditTodoItemSection.Count.rawValue - 1 : EditTodoItemSection.Count.rawValue
        } else {
            return EditTodoItemSection.Count.rawValue - 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch EditTodoItemSection(rawValue: section) ?? .Count {
        case .Info:
            return 3
        case .Repeat:
            return repeatsSwitch.on ? 2 : 1
        case .Due:
            return dueSwitch.on ? 2 : 1
        case .Count:
            return 0
        }
    }
    
    @IBAction func repeatsSwitchChanged() {
        tableView.reloadData()
    }
    
    @IBAction func dueSwitchChanged() {
        tableView.reloadData()
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        item?.name = nameTextField.text ?? "Untitled"
        item?.repeats = repeatsSwitch.on
        item?.points = Int(pointsTextField.text ?? "0") ?? 0
        item?.minutes = Int(minutesTextField.text ?? "0") ?? 0
        item?.repeatCount = Int(repeatCountTextField.text ?? "0") ?? 0
        if dueSwitch.on {
            item?.dueDate = Date(date: datePicker.date)
        } else {
            item?.dueDate = nil
        }
        
        saveFunction()
        navigationController?.popViewControllerAnimated(true)
    }

}
