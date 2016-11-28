//
//  DayViewController.swift
//  Todo
//
//  Created by Heather Shelley on 11/26/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import UIKit

enum DayViewControllerRegularSection: Int {
    case info
    case pastDue
    case today
    case count
}

class DayViewController: UITableViewController {
    
    let timeFormatter = DateFormatter()
    let dayFormatter = DateFormatter()
    
    var todayList = List()
    var pastDueItems = [(item: TodoItem, listID: String)]()
    var anytimeSections: [(name: String, list: List)] = []
    var day: Day?
    var isNewDay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        
        timeFormatter.amSymbol = "am"
        timeFormatter.pmSymbol = "pm"
        timeFormatter.dateFormat = "h:mma"
        
        dayFormatter.dateFormat = "EEE, MMM d"
        
        NotificationCenter.default.addObserver(self, selector: #selector(DayViewController.significantTimeChange(_:)), name: NSNotification.Name.UIApplicationSignificantTimeChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DayViewController.profileChanged(_:)), name: NSNotification.Name(rawValue: ProfileChangedNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func updateData() {
        if let day = day {
            navigationItem.title = dayFormatter.string(from: day.date.date as Date)
            todayList = UserDataController.sharedController().listWithID(day.listID)
            UserDataController.sharedController().updateDayListFromTemplates(list: todayList, forDate: day.date)
            pastDueItems = UserDataController.sharedController().pastDueItems()
            anytimeSections = UserDataController.sharedController().anytimeListsForDate(day.date).filter() { $0.list.items.count > 0 }
            tableView.reloadData()
        } else {
            day = UserDataController.sharedController().dayForDate(Date(date: Foundation.Date()))
        }
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) -> Void {
        let position = (todayList.items.last?.position ?? (todayList.items.count - 1)) + 1
        let item = TodoItem(name: "New Item", position: position)
        todayList.items.append(item)
        UserDataController.sharedController().addOrUpdateList(todayList)
        let indexPath = IndexPath(row: position, section: DayViewControllerRegularSection.today.rawValue)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == DayViewControllerRegularSection.today.rawValue
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == DayViewControllerRegularSection.today.rawValue
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = todayList.items.remove(at: sourceIndexPath.row)
        todayList.items.insert(movedItem, at: destinationIndexPath.row)
        for (i, t) in todayList.items.enumerated() {
            t.position = i
        }
        UserDataController.sharedController().addOrUpdateList(todayList)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DayViewControllerRegularSection.count.rawValue + anytimeSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < DayViewControllerRegularSection.count.rawValue {
            switch DayViewControllerRegularSection(rawValue: section) ?? .count {
            case .info:
                return 1
            case .pastDue:
                return pastDueItems.count
            case .today:
                return todayList.items.count
            case .count:
                return 0
            }
        } else {
            return anytimeSections[section - DayViewControllerRegularSection.count.rawValue].list.items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! DayInfoCell
            let (completedPoints, totalPoints, remainingTime, totalTime) = todayList.items.reduce((0, 0, 0, 0)) { (current: (completedPoints: Int, totalPoints: Int, remainingTime: Int, totalTime: Int), item) in
                let newCompletedPoints = current.completedPoints + {
                    if item.repeats {
                        return item.points * item.numberCompleted
                    } else {
                        return item.completed ? item.points : 0
                    }
                }()
                
                let newTotalPoints = current.totalPoints + (item.points * (item.repeatCount > 0 ? item.repeatCount : 1))
                
                let newRemainingTime = current.remainingTime + {
                    if item.repeats {
                        return item.minutes * max(0, item.repeatCount - item.numberCompleted)
                    } else {
                        return item.completed ? 0 : item.minutes
                    }
                }()
                
                let newTotalTime = current.totalTime + (item.minutes * (item.repeatCount > 0 ? item.repeatCount : 1))
                
                return (newCompletedPoints, newTotalPoints, newRemainingTime, newTotalTime)
            }
            cell.pointsLabel.text = "\(completedPoints)/\(totalPoints)"
            
            let (totalTimeHours, totalTimeMinutes) = quotientAndRemainder(totalTime, divisor: 60)
            cell.totalTimeLabel.text = String(format: "%d:%02d", totalTimeHours, totalTimeMinutes)
            
            let endTime = Foundation.Date().addingTimeInterval(TimeInterval(remainingTime * 60))
            cell.endTimeLabel.text = timeFormatter.string(from: endTime)
            
            return cell
        } else {
            guard let item = itemAtIndexPath(indexPath) else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
            cell.textLabel?.text = (item.repeats && item.repeatCount > 0 ? "\(item.numberCompleted)/\(item.repeatCount) " : "") + item.name
            var detailText = ""
            if item.minutes > 0 {
                detailText += "\(item.minutes)min,"
            }
            detailText += "\(item.points)pts"
            cell.detailTextLabel?.text = detailText
            if item.completed {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = itemAtIndexPath(indexPath) else { return }
        
        if isEditing {
            if !item.completed {
                performSegue(withIdentifier: "EditItemSegue", sender: item)
            } else {
                let alertController = UIAlertController(title: "Cannot Edit", message: "You cannot edit a completed item.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        } else {
            let updateFunc: () -> Void = {
                if let list = self.listForIndexPath(indexPath) {
                    UserDataController.sharedController().addOrUpdateList(list)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }
            if item.repeats {
                let alertController = UIAlertController(title: "Completed", message: "How many of the specified task were completed?", preferredStyle: UIAlertControllerStyle.alert)
                let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                    let numberTextField = alertController.textFields![0] 
                    if let numberComplete = Int(numberTextField.text!) {
                        let pointsToAdd = numberComplete * item.points
                        item.numberCompleted += numberComplete
                        item.completed = item.repeatCount > 0 && item.numberCompleted >= item.repeatCount
                        UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: numberComplete)
                        updateFunc()
                        
                        let successAlert = UIAlertController(title: "Success", message: "Successfully added \(pointsToAdd) points to store.", preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { _ in }
                        successAlert.addAction(cancelAction)
                        self.present(successAlert, animated: true, completion: nil)
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
                item.completed = !item.completed
                let numberCompleted = item.completed ? 1 : -1
                UserDataController.sharedController().updateWithCompletedItem(item, numberComplete: numberCompleted)
                
                updateFunc()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < DayViewControllerRegularSection.count.rawValue {
            switch DayViewControllerRegularSection(rawValue: section) ?? .count {
            case .info:
                return nil
            case .pastDue:
                return pastDueItems.isEmpty ? nil : "Past Due"
            case .today:
                return "Today"
            case .count:
                return nil
            }
        } else {
            return "\(anytimeSections[section - 3].name) - Anytime"
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todayList.items.remove(at: indexPath.row)
            UserDataController.sharedController().addOrUpdateList(todayList)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    fileprivate func listForIndexPath(_ indexPath: IndexPath) -> List? {
        if indexPath.section < DayViewControllerRegularSection.count.rawValue {
            switch DayViewControllerRegularSection(rawValue: indexPath.section) ?? .count {
            case .info:
                return nil
            case .pastDue:
                return UserDataController.sharedController().listWithID(pastDueItems[indexPath.row].listID)
            case .today:
                return todayList
            case .count:
                return nil
            }
        } else {
            return anytimeSections[indexPath.section - DayViewControllerRegularSection.count.rawValue].list
        }
    }
    
    fileprivate func itemAtIndexPath(_ indexPath: IndexPath) -> TodoItem? {
        if indexPath.section < DayViewControllerRegularSection.count.rawValue {
            switch DayViewControllerRegularSection(rawValue: indexPath.section) ?? .count {
            case .info:
                return nil
            case .pastDue:
                return pastDueItems[indexPath.row].item
            case .today:
                return todayList.items[indexPath.row]
            case .count:
                return nil
            }
        } else {
            return anytimeSections[indexPath.section - DayViewControllerRegularSection.count.rawValue].list.items[indexPath.row]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let item = sender as? TodoItem {
            if let editViewController = segue.destination as? EditTodoItemTableViewController {
                editViewController.item = item
                editViewController.anytime = false
                editViewController.saveFunction = {
                    UserDataController.sharedController().addOrUpdateList(self.todayList)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    fileprivate func quotientAndRemainder(_ dividend: Int, divisor: Int) -> (Int, Int) {
        return (dividend / divisor, dividend % divisor)
    }
    
    func significantTimeChange(_: Notification) {
        isNewDay = true
    }
    
    func applicationDidBecomeActive(_: Notification) {
        if isNewDay {
            isNewDay = false
            day = UserDataController.sharedController().dayForDate(Date(date: Foundation.Date()))
            updateData()
        }
    }
    
    func profileChanged(_: Notification) {
        day = nil
        updateData()
    }
    
}
