//
//  TemplatesViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/6/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class TemplatesViewController: UITableViewController {
    
    var orderItemsButton: UIBarButtonItem!
    var sections: [(title: String, templates: [Template])] = []
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem
        orderItemsButton = UIBarButtonItem(title: "Order Items", style: .plain, target: self, action: #selector(TemplatesViewController.orderItems))
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateData()
        tableView.reloadData()
    }
    
    fileprivate func updateData() {
        let templates = UserDataController.sharedController().allTemplates()
        sections = [("Regular", templates.filter { !$0.anytime }), ("Anytime", templates.filter { $0.anytime })]
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) -> Void {
        let templates = sections[0].templates
        let position = templates.count
        let template = Template(name: "New Template", position: position)
        UserDataController.sharedController().addOrUpdateTemplate(template)
        updateData()
        let indexPath = IndexPath(row: position, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table View
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            navigationItem.rightBarButtonItems?.append(orderItemsButton)
        } else if let index = navigationItem.rightBarButtonItems?.index(of: orderItemsButton) {
            navigationItem.rightBarButtonItems?.remove(at: index)
        }
        super.setEditing(editing, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return sourceIndexPath.section == proposedDestinationIndexPath.section ? proposedDestinationIndexPath : sourceIndexPath
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTemplate = sections[sourceIndexPath.section].templates.remove(at: sourceIndexPath.row)
        sections[destinationIndexPath.section].templates.insert(movedTemplate, at: destinationIndexPath.row)
        for section in sections {
            for (i, t) in section.templates.enumerated() {
                t.position = i
            }
            
            UserDataController.sharedController().updateTemplates(section.templates)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].templates.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].templates.count > 0 ? sections[section].title : nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        let templates = sections[indexPath.section].templates
        cell.textLabel?.text = templates[indexPath.row].name
        cell.detailTextLabel?.text = daysStringFromTemplateDays(templates[indexPath.row].templateDays)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = sections[indexPath.section].templates[indexPath.row]
        if isEditing {
            let alertController = UIAlertController(title: "Edit Title", message: nil, preferredStyle: .alert)
            alertController.addTextField() { textField in
                textField.text = template.name
                textField.autocapitalizationType = .words
                textField.clearButtonMode = UITextFieldViewMode.whileEditing
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
                let textField = alertController.textFields!.first!
                template.name = textField.text!
                UserDataController.sharedController().addOrUpdateTemplate(template)
                self.updateData()
                self.tableView.reloadData()
            }))
            self .present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "TemplateDetailSegue", sender: template)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var templates = sections[indexPath.section].templates
            UserDataController.sharedController().removeTemplate(templates[indexPath.row])
            updateData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TemplateViewController {
            destination.template = sender as! Template
        }
    }
    
    // MARK: - Private Functions
    
    func orderItems() {
        performSegue(withIdentifier: "OrderItems", sender: nil)
    }
    
}
