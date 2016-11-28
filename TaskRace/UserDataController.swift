//
//  UserDataController.swift
//  Todo
//
//  Created by Heather Shelley on 10/23/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation
import YapDatabase

let ProfileChangedNotification = "ProfileChangedNotification"

struct UserDataController {
    fileprivate static var sharedInstance = UserDataController()
    let database: YapDatabase
    let connection: YapDatabaseConnection
    static var currentProfile: String {
        get {
            return UserDefaults.standard.string(forKey: "current_profile") ?? "Default"
        }
        set {
            let currentProfile = UserDefaults.standard.string(forKey: "current_profile") ?? ""
            if newValue != currentProfile {
                UserDefaults.standard.set(newValue, forKey: "current_profile")
                sharedInstance = UserDataController()
                NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileChangedNotification), object: nil)
            }
        }
    }
    
    static func sharedController() -> UserDataController {
        return UserDataController.sharedInstance
    }
    
    fileprivate init() {
        database = YapDatabase(path: UserDataController.databasePath())
        connection = database.newConnection()
    }
    
    fileprivate static func databasePath() -> String {
        let dbPath = databasePathForProfile(currentProfile)
        do {
            try FileManager.default.createDirectory(atPath: (dbPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        return dbPath
    }
    
    fileprivate static func databasePathForProfile(_ profile: String) -> String {
        return (NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString).appendingPathComponent(profile + "Data")
    }
    
    // MARK: - Profiles
    
    static func allProfiles() -> [String] {
        return UserDefaults.standard.array(forKey: "profiles") as? [String] ?? []
    }
    
    static func addProfile(_ profile: String) {
        var profiles = allProfiles()
        profiles.append(profile)
        UserDefaults.standard.set(profiles, forKey: "profiles")
    }
    
    static func renameProfile(_ currentName: String, toProfile newName: String) {
        var profiles = allProfiles()
        if let index = profiles.index(of: currentName) {
            profiles[index] = newName
            let directory = (databasePathForProfile(currentName) as NSString).deletingLastPathComponent
            for filename in try! FileManager.default.contentsOfDirectory(atPath: directory) {
                if filename.hasPrefix(currentName) {
                    do {
                        try FileManager.default.moveItem(atPath: (directory as NSString).appendingPathComponent(filename), toPath: (directory as NSString).appendingPathComponent(filename.replacingOccurrences(of: currentName, with: newName)))
                    }
                    catch let error {
                        print(error)
                    }
                }
            }
            UserDefaults.standard.set(profiles, forKey: "profiles")
            
            if currentName == currentProfile {
                currentProfile = newName
            }
        }
    }
    
    static func removeProfile(_ profile: String) {
        var profiles = allProfiles()
        if profiles.count > 0 {
            profiles.remove(at: profiles.index(of: profile)!)
            UserDefaults.standard.set(profiles, forKey: "profiles")
            if profile == currentProfile {
                currentProfile = profiles.count > 0 ? profiles[0] : "Default"
            }
        }
    }
    
    // MARK: - Settings
    
    func useGlobalOrdering() -> Bool {
        return UserDefaults.standard.bool(forKey: "useGlobalOrdering")
    }
    
    func setUseGlobalOrdering(_ useGlobal: Bool) {
        UserDefaults.standard.set(useGlobal, forKey: "useGlobalOrdering")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Templates
    
    func allTemplates() -> [Template] {
        var templates: [Template] = []
        connection.read() { transaction in
            transaction.enumerateKeysAndObjects(inCollection: "templates") { key, object, _ in
                if let template = object as? Template {
                    templates.append(template)
                }
            }
        }
        
        return templates.sorted { $0.position < $1.position }
    }
    
    func regularTemplateLists() -> [List] {
        return allTemplates().flatMap { template in
            if !template.anytime {
                if let listID = template.listID {
                    return self.listWithID(listID)
                }
            }
            
            return nil
        }
    }
    
    func containsTemplate(_ template: Template) -> Bool {
        var hasTemplate = false
        connection.read { transaction in
            if (transaction.object(forKey: template.id, inCollection: "templates") as? Template) != nil {
                hasTemplate = true
            }
        }
        
        return hasTemplate
    }
    
    func addOrUpdateTemplate(_ template: Template) -> Void {
        connection.readWrite() { transaction in
            transaction.setObject(template, forKey: template.id, inCollection: "templates")
        }
    }
    
    func updateTemplates(_ templates: [Template]) -> Void {
        connection.readWrite() { transaction in
            for template in templates {
                transaction.setObject(template, forKey: template.id, inCollection: "templates")
            }
        }
    }
    
    func removeTemplate(_ template: Template) -> Void {
        connection.readWrite() { transaction in
            transaction.removeObject(forKey: template.id, inCollection: "templates")
        }
    }
    
    // MARK: - Days
    
    func dayForDate(_ date: Date) -> Day {
        var days: [Day] = []
        connection.read() { transaction in
            transaction.enumerateKeysAndObjects(inCollection: "days") { key, object, _ in
                if let day = object as? Day {
                    days.append(day)
                }
            }
        }
        
        let day: Day
        if let existingDay = days.filter({ $0.date == date }).first {
            day = existingDay
        } else {
            let list = List()
            addOrUpdateList(list)
            day = Day(date: date, listID: list.id)
            addOrUpdateDay(day)
        }
        
        return day
    }
    
    fileprivate func addOrUpdateDay(_ day: Day) -> Void {
        connection.readWrite() { transaction in
            transaction.setObject(day, forKey: day.id, inCollection: "days")
        }
    }
    
    // MARK: - Lists
    
    func listWithID(_ id: String) -> List {
        var list: List? = nil
        connection.read() { transaction in
            list = transaction.object(forKey: id, inCollection: "lists") as? List
        }
        if let list = list {
            return list
        } else {
            assert(false, "No list returned for id \(id)")
            return List()
        }
    }
    
    func emptyList() -> List {
        let list = List()
        addOrUpdateList(list)
        return list
    }
    
    func updateDayListFromTemplates(list: List, forDate date: Date) -> List {
        let templates = allTemplates()
        for template in templates {
            if !template.anytime && template.templateDays.intersection(date.dayOfWeek) {
                if let listID = template.listID {
                    let templateList = listWithID(listID)
                    for templateItem in templateList.items {
                        if let index = list.items.index(of: templateItem) {
                            let item = list.items[index]
                            item.updateFromItem(templateItem)
                        } else {
                            let newItem = templateItem.copy() as! TodoItem
                            list.items.append(newItem)
                        }
                    }
                }
            }
        }
        
        if useGlobalOrdering() {
            list.items.sort { $0.position <= $1.position }
        }
        
        addOrUpdateList(list)
        return list
    }
    
    func addOrUpdateList(_ list: List) -> Void {
        connection.readWrite() { transaction in
            transaction.setObject(list, forKey: list.id, inCollection: "lists")
        }
    }
    
    func anytimeListsForDate(_ date: Date) -> [(name: String, list: List)] {
        return allTemplates().flatMap { template -> (String, List)? in
            if template.anytime && template.templateDays.intersection(date.dayOfWeek) {
                if let id = template.listID {
                    let list = self.listWithID(id)
                    list.items = list.items.filter() { item in
                        return !item.completed
                    }
                    return (template.name, list	)
                }
            }
            return nil
        }
    }
    
    func pastDueItems() -> [(item: TodoItem, listID: String)] {
        return allTemplates().flatMap { template -> [(item: TodoItem, listID: String)] in
            guard template.anytime, let id = template.listID else { return [] }
            let list = self.listWithID(id)
            let today = Date(date: Foundation.Date())
            return list.items.filter {
                if let dueDate = $0.dueDate {
                    return !$0.completed && dueDate <= today
                }
                return false
                }.sorted { $0.dueDate! > $1.dueDate! }.map { ($0, id) }
        }
    }
    
    // MARK: - Store
    
    func storePoints() -> Int {
        var points = 0
        connection.read() { transaction in
            if let pts = transaction.object(forKey: "points", inCollection: "store") as? NSNumber {
                points = pts.intValue
            }
        }
        
        return points
    }
    
    func updateWithCompletedItem(_ item: AnyObject, numberComplete: Int) -> Void {
        let pointsToAdd: Int = {
            switch item {
            case let storeItem as StoreItem:
                return numberComplete * -storeItem.points
            case let todoItem as TodoItem:
                return numberComplete * todoItem.points
            default:
                return 0
            }
        }()
        
        if pointsToAdd != 0 {
            connection.readWrite() { transaction in
                var currentPoints = 0
                if let storePoints = transaction.object(forKey: "points", inCollection: "store") as? NSNumber {
                    currentPoints += storePoints.intValue
                }
                transaction.setObject(NSNumber(value: currentPoints + pointsToAdd as Int), forKey: "points", inCollection: "store")
                
                let historyItem = HistoryItem(name: item.name, points: pointsToAdd, dateCompleted: Foundation.Date(), numberCompleted: numberComplete)
                transaction.setObject(historyItem, forKey: historyItem.id, inCollection: "history")
            }
        }
    }
    
    func storeItems() -> [StoreItem] {
        var items: [StoreItem] = []
        connection.read() { transaction in
            transaction.enumerateKeysAndObjects(inCollection: "store") { key, object, _ in
                if let item = object as? StoreItem {
                    items.append(item)
                }
            }
        }
        
        return items.sorted { $0.position < $1.position }
    }
    
    func addOrUpdateStoreItem(_ item: StoreItem) -> Void {
        connection.readWrite() { transaction in
            transaction.setObject(item, forKey: item.id, inCollection: "store")
        }
    }
    
    func deleteStoreItem(_ item: StoreItem) -> Void {
        connection.readWrite() { transaction in
            transaction.removeObject(forKey: item.id, inCollection: "store")
        }
    }
    
    func updateStoreItems(_ items: [StoreItem]) -> Void {
        connection.readWrite() { transaction in
            for item in items {
                transaction.setObject(item, forKey: item.id, inCollection: "store")
            }
        }
    }
    
    // MARK: - History
    
    func historyItems() -> [HistoryItem] {
        var items: [HistoryItem] = []
        connection.read() { transaction in
            transaction.enumerateKeysAndObjects(inCollection: "history") { key, object, _ in
                if let item = object as? HistoryItem {
                    items.append(item)
                }
            }
        }
        
        return items.sorted { $0.dateCompleted.timeIntervalSince1970 > $1.dateCompleted.timeIntervalSince1970 }
    }
}
