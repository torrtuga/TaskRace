//
//  EditStoreItemViewController.swift
//  Todo
//
//  Created by Heather Shelley on 12/6/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class EditStoreItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pointsTextField: UITextField!
    @IBOutlet weak var repeatsSwitch: UISwitch!
    var item: StoreItem!
    var saveFunction: (name: String, points: Int?, repeats: Bool) -> Void = {_, _, _ in print("Save function not implemented") }
    
    override func viewDidLoad() {
        nameTextField.text = item.name
        nameTextField.autocapitalizationType = .Sentences
        pointsTextField.text = "\(item.points)"
        repeatsSwitch.on = item.repeats
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        saveFunction(name: nameTextField.text!, points: Int(pointsTextField.text!), repeats: repeatsSwitch.on)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return Int(text) != nil
    }
}