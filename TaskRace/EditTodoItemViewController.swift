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
    @IBOutlet weak var repeatsSwitch: UISwitch!
    var item: TodoItem!
    var saveFunction: (name: String, points: Int?, minutes: Int?, repeats: Bool) -> Void = {_, _, _, _ in println("Save function not implemented") }
    
    override func viewDidLoad() {
        nameTextField.text = item.name
        nameTextField.autocapitalizationType = .Sentences
        pointsTextField.text = "\(item.points)"
        minutesTextField.text = "\(item.minutes)"
        repeatsSwitch.on = item.repeats
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        saveFunction(name: nameTextField.text, points: pointsTextField.text.toInt(), minutes: minutesTextField.text.toInt(), repeats: repeatsSwitch.on)
        navigationController?.popViewControllerAnimated(true)
    }
}
