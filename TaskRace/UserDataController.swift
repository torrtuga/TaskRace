//
//  UserDataController.swift
//  Todo
//
//  Created by Heather Shelley on 10/23/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

struct UserDataController {
    private static let sharedInstance = UserDataController()
    let database: YapDatabase
    let connection: YapDatabaseConnection
    
    static func sharedController() -> UserDataController {
        return UserDataController.sharedInstance
    }
    
    private init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingPathComponent("data")
        NSFileManager.defaultManager().createDirectoryAtPath(dbPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        database = YapDatabase(path: dbPath)
        connection = database.newConnection()
    }
    
    // MARK: - Templates
    
    func allTemplates() -> [Template] {
        var templates: [Template] = []
        self.connection.readWithBlock() { transaction in
            transaction.enumerateKeysAndObjectsInCollection("templates") { key, object, _ in
                if let template = object as? Template {
                    templates.append(template)
                }
            }
        }
        
        return sorted(templates) { $0.position < $1.position }
    }
    
    func addOrUpdateTemplate(template: Template) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.setObject(template, forKey: template.id, inCollection: "templates")
        }
    }
    
    func updateTemplates(templates: [Template]) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            for template in templates {
                transaction.setObject(template, forKey: template.id, inCollection: "templates")
            }
        }
    }
    
    func removeTemplate(template: Template) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.removeObjectForKey(template.id, inCollection: "templates")
        }
    }
    
    // MARK: - Days
    
    func allDays() -> [Day] {
        var days: [Day] = []
        self.connection.readWithBlock() { transaction in
            transaction.enumerateKeysAndObjectsInCollection("days") { key, object, _ in
                if let day = object as? Day {
                    days.append(day)
                }
            }
        }
        
        let today = Date(date: NSDate())
        if days.indexOf({ day in day.date == today }) == nil {
            let day = Day(date: today)
            self.connection.readWriteWithBlock() { transaction in
                transaction.setObject(day, forKey: day.id, inCollection: "days")
            }
            days.append(day)
        }
        
        return sorted(days) { $0.date < $1.date }
    }
    
    func addOrUpdateDay(day: Day) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.setObject(day, forKey: day.id, inCollection: "days")
        }
    }
    
    func dayForToday() -> Day {
        let days = allDays()
        let today = Date(date: NSDate())
        return days[days.indexOf({ day in day.date == today })!]
    }
    
    // MARK: - Lists
    
    func listWithID(id: String) -> List {
        var list: List? = nil
        self.connection.readWithBlock() { transaction in
            list = transaction.objectForKey(id, inCollection: "lists") as? List
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
    
    func updateDayListFromTemplates(#list: List, forDate date: Date) -> List {
        let templates = allTemplates()
        for template in templates {
            if !template.anytime && template.templateDays & date.dayOfWeek {
                if let listID = template.listID {
                    let templateList = listWithID(listID)
                    templateList.items.each() { (templateItem: TodoItem) -> Void in
                        if let index = list.items.indexOf(templateItem) {
                            let item = list.items[index]
                            item.updateFromItem(templateItem)
                        } else {
                            let newItem = templateItem.copy() as TodoItem
                            list.items.append(newItem)
                        }
                    }
                }
            }
        }
        
        addOrUpdateList(list)
        return list
    }
    
    func addOrUpdateList(list: List) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.setObject(list, forKey: list.id, inCollection: "lists")
        }
    }
    
    func anytimeListsForDate(date: Date) -> [(name: String, list: List)] {
        return allTemplates().mapFilter() { template -> (String, List)? in
            if template.anytime && template.templateDays & date.dayOfWeek {
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
    
    // MARK: - Store
    
    func storePoints() -> Int {
        var points = 0
        self.connection.readWithBlock() { transaction in
            if let pts = transaction.objectForKey("points", inCollection: "store") as? NSNumber {
                points = pts.integerValue
            }
        }
        
        return points
    }
    
    func updateWithCompletedItem(item: AnyObject, numberComplete: Int) -> Void {
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
            self.connection.readWriteWithBlock() { transaction in
                var currentPoints = 0
                if let storePoints = transaction.objectForKey("points", inCollection: "store") as? NSNumber {
                    currentPoints += storePoints.integerValue
                }
                transaction.setObject(NSNumber(integer: currentPoints + pointsToAdd), forKey: "points", inCollection: "store")
                
                let historyItem = HistoryItem(name: item.name, points: pointsToAdd, dateCompleted: NSDate(), numberCompleted: numberComplete)
                transaction.setObject(historyItem, forKey: historyItem.id, inCollection: "history")
            }
        }
    }
    
    func storeItems() -> [StoreItem] {
        var items: [StoreItem] = []
        self.connection.readWithBlock() { transaction in
            transaction.enumerateKeysAndObjectsInCollection("store") { key, object, _ in
                if let item = object as? StoreItem {
                    items.append(item)
                }
            }
        }
        
        return sorted(items) { $0.position < $1.position }
    }
    
    func addOrUpdateStoreItem(item: StoreItem) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.setObject(item, forKey: item.id, inCollection: "store")
        }
    }
    
    func deleteStoreItem(item: StoreItem) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.removeObjectForKey(item.id, inCollection: "store")
        }
    }
    
    func updateStoreItems(items: [StoreItem]) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            items.each() { item in
                transaction.setObject(item, forKey: item.id, inCollection: "store")
            }
        }
    }
    
    // MARK: - History
    
    func historyItems() -> [HistoryItem] {
        var items: [HistoryItem] = []
        self.connection.readWithBlock() { transaction in
            transaction.enumerateKeysAndObjectsInCollection("history") { key, object, _ in
                if let item = object as? HistoryItem {
                    items.append(item)
                }
            }
        }
        
        return sorted(items) { $0.dateCompleted.timeIntervalSince1970 > $1.dateCompleted.timeIntervalSince1970 }
    }
}
