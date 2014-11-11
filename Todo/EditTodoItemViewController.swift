//
//  EditTodoItemViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/11/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class EditTodoItemViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointsTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    var item: TodoItem!
    var saveFunction: (name: String, points: Int?, minutes: Int?) -> Void = {_, _, _ in println("Save function not implemented") }
    
    override func viewDidLoad() {
        nameTextField.text = item.name
        pointsTextField.text = "\(item.points)"
        minutesTextField.text = "\(item.minutes)"
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        saveFunction(name: nameTextField.text, points: pointsTextField.text.toInt(), minutes: minutesTextField.text.toInt())
        navigationController?.popViewControllerAnimated(true)
    }
}
