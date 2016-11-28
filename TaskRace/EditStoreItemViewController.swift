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
    var saveFunction: (_ name: String, _ points: Int?, _ repeats: Bool) -> Void = {_, _, _ in print("Save function not implemented") }
    
    override func viewDidLoad() {
        nameTextField.text = item.name
        nameTextField.autocapitalizationType = .sentences
        pointsTextField.text = "\(item.points)"
        repeatsSwitch.isOn = item.repeats
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        saveFunction(nameTextField.text!, Int(pointsTextField.text!), repeatsSwitch.isOn)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        return Int(text) != nil
    }
}
