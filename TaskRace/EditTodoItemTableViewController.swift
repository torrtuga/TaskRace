//
//  EditTodoItemViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/11/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

enum EditTodoItemSection: Int {
    case info
    case `repeat`
    case due
    case count
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
            nameTextField.autocapitalizationType = .sentences
            pointsTextField.text = "\(item.points)"
            minutesTextField.text = "\(item.minutes)"
            repeatsSwitch.isOn = item.repeats
            repeatCountTextField.text = "\(item.repeatCount)"
            dueSwitch.isOn = item.dueDate != nil
            if let dueDate = item.dueDate {
                datePicker.date = dueDate.date as Date
            }
            tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if anytime {
            return repeatsSwitch.isOn ? EditTodoItemSection.count.rawValue - 1 : EditTodoItemSection.count.rawValue
        } else {
            return EditTodoItemSection.count.rawValue - 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch EditTodoItemSection(rawValue: section) ?? .count {
        case .info:
            return 3
        case .repeat:
            return repeatsSwitch.isOn ? 2 : 1
        case .due:
            return dueSwitch.isOn ? 2 : 1
        case .count:
            return 0
        }
    }
    
    @IBAction func repeatsSwitchChanged() {
        tableView.reloadData()
    }
    
    @IBAction func dueSwitchChanged() {
        tableView.reloadData()
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        item?.name = nameTextField.text ?? "Untitled"
        item?.repeats = repeatsSwitch.isOn
        item?.points = Int(pointsTextField.text ?? "0") ?? 0
        item?.minutes = Int(minutesTextField.text ?? "0") ?? 0
        item?.repeatCount = Int(repeatCountTextField.text ?? "0") ?? 0
        if dueSwitch.isOn {
            item?.dueDate = Date(date: datePicker.date)
        } else {
            item?.dueDate = nil
        }
        
        saveFunction()
        navigationController?.popViewController(animated: true)
    }

}
