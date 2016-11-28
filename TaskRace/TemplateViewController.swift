//
//  TemplateViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/8/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

class TemplateViewController: UITableViewController {
    
    var list: List!
    var template: Template! {
        didSet {
            if let template = template {
                navigationItem.title = template.name
                if let listID = template.listID {
                    list = UserDataController.sharedController().listWithID(listID)
                } else {
                    list = List()
                    template.listID = list.id
                    UserDataController.sharedController().addOrUpdateList(list)
                    UserDataController.sharedController().addOrUpdateTemplate(template)
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems?.append(editButtonItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDataController.sharedController().containsTemplate(template) {
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) -> Void {
        let position = list.items.count
        let item = TodoItem(name: "New Item", position: position)
        list.items.append(item)
        UserDataController.sharedController().addOrUpdateList(list)
        let indexPath = IndexPath(row: position, section: 2)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 1
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = list.items.remove(at: sourceIndexPath.row)
        list.items.insert(movedItem, at: destinationIndexPath.row)
        
        // Update position
        if destinationIndexPath.row > 0 {
            movedItem.position = list.items[destinationIndexPath.row - 1].position
        } else if destinationIndexPath.row >= list.items.count {
            movedItem.position = list.items[destinationIndexPath.row + 1].position
        } else {
            movedItem.position = 10000000
        }
        UserDataController.sharedController().addOrUpdateList(list)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 7
        } else {
            return list.items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) 
            cell.textLabel?.text = "Anytime"
            let anytimeSwitch = UISwitch()
            anytimeSwitch.isOn = template.anytime
            anytimeSwitch.addTarget(self, action: #selector(TemplateViewController.switchValueChanged(_:)), for: UIControlEvents.valueChanged)
            cell.accessoryView = anytimeSwitch
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) 
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = TemplateDays.Sunday.stringValue
                cell.tag = Int(TemplateDays.Sunday.rawValue)
            case 1:
                cell.textLabel?.text = TemplateDays.Monday.stringValue
                cell.tag = Int(TemplateDays.Monday.rawValue)
            case 2:
                cell.textLabel?.text = TemplateDays.Tuesday.stringValue
                cell.tag = Int(TemplateDays.Tuesday.rawValue)
            case 3:
                cell.textLabel?.text = TemplateDays.Wednesday.stringValue
                cell.tag = Int(TemplateDays.Wednesday.rawValue)
            case 4:
                cell.textLabel?.text = TemplateDays.Thursday.stringValue
                cell.tag = Int(TemplateDays.Thursday.rawValue)
            case 5:
                cell.textLabel?.text = TemplateDays.Friday.stringValue
                cell.tag = Int(TemplateDays.Friday.rawValue)
            case 6:
                cell.textLabel?.text = TemplateDays.Saturday.stringValue
                cell.tag = Int(TemplateDays.Saturday.rawValue)
            default:
                cell.textLabel?.text = "Not handled"
            }
            if template!.templateDays.rawValue & UInt(cell.tag) != 0 {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) 
            let item = list.items[indexPath.row]
            cell.textLabel?.text = item.name
            var detailText = ""
            if item.minutes > 0 {
                detailText += "\(item.minutes)min,"
            }
            detailText += "\(item.points)pts"
            cell.detailTextLabel?.text = detailText
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func switchValueChanged(_ sender: UISwitch) {
        template.anytime = sender.isOn
        UserDataController.sharedController().addOrUpdateTemplate(template)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath)!
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                template.templateDays = template.templateDays.symmetricDifference(TemplateDays(UInt(cell.tag)))
            } else {
                cell.accessoryType = .checkmark
                template.templateDays = template.templateDays.union(TemplateDays(UInt(cell.tag)))
            }
            UserDataController.sharedController().addOrUpdateTemplate(template)
        } else if indexPath.section == 2 {
            print(template)
            print(list)
            for item in self.list.items {
                print("\(item.name), \(item.dueDate)")
            }
            let item = list.items[indexPath.row]
            performSegue(withIdentifier: "EditItemSegue", sender: item)
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
            list.items.remove(at: indexPath.row)
            UserDataController.sharedController().addOrUpdateList(list)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let item = sender as? TodoItem {
            if let editViewController = segue.destination as? EditTodoItemTableViewController {
                editViewController.item = item
                editViewController.anytime = template.anytime
                editViewController.saveFunction = {
                    UserDataController.sharedController().addOrUpdateList(self.list)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
