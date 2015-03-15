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
    @IBOutlet weak var repeatCountLabel: UILabel!
    @IBOutlet weak var repeatHintLabel: UILabel!
    @IBOutlet weak var repeatCountTextField: UITextField!
    
    var item: TodoItem?
    var saveFunction: (name: String, points: Int?, minutes: Int?, repeats: Bool, repeatCount: Int?) -> Void = {_, _, _, _, _ in println("Save function not implemented") }
    
    override func viewDidLoad() {
        if let item = item {
            nameTextField.text = item.name
            nameTextField.autocapitalizationType = .Sentences
            pointsTextField.text = "\(item.points)"
            minutesTextField.text = "\(item.minutes)"
            repeatsSwitch.on = item.repeats
            repeatCountTextField.text = "\(item.repeatCount)"
            updateHidden()
        }
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func repeatsSwitchChanged() {
        updateHidden()
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        saveFunction(name: nameTextField.text, points: pointsTextField.text.toInt(), minutes: minutesTextField.text.toInt(), repeats: repeatsSwitch.on, repeatCount: repeatCountTextField.text.toInt())
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func updateHidden() {
        repeatCountLabel.hidden = !repeatsSwitch.on
        repeatCountTextField.hidden = !repeatsSwitch.on
        repeatHintLabel.hidden = !repeatsSwitch.on
    }
}
