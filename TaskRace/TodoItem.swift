//
//  TodoItem.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class TodoItem: NSObject, NSCoding, NSCopying {
    let id: String
    var name: String
    var points: Int
    var minutes: Int
    var completed: Bool
    var position: Int
    var repeats: Bool
    var repeatCount: Int
    var numberCompleted: Int
    var dueDate: Date?
    
    fileprivate init(id: String, name: String, position: Int) {
        self.id = id
        self.name = name
        points = 0
        minutes = 0
        completed = false
        self.position = position
        repeats = false
        repeatCount = 0
        numberCompleted = 0
        dueDate = nil
    }
    
    convenience init(name: String, position: Int) {
        self.init(id: UUID().uuidString, name: name, position: position)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? TodoItem {
            return self.id == other.id
        }
        
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        points = aDecoder.decodeInteger(forKey: "points")
        minutes = aDecoder.decodeInteger(forKey: "minutes")
        completed = aDecoder.decodeBool(forKey: "completed")
        position = aDecoder.decodeInteger(forKey: "position")
        repeats = aDecoder.decodeBool(forKey: "repeats")
        repeatCount = aDecoder.decodeInteger(forKey: "repeatCount")
        numberCompleted = aDecoder.decodeInteger(forKey: "numberCompleted")
        dueDate = aDecoder.decodeObject(forKey: "dueDate") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(points, forKey: "points")
        aCoder.encode(minutes, forKey: "minutes")
        aCoder.encode(completed, forKey: "completed")
        aCoder.encode(position, forKey: "position")
        aCoder.encode(repeats, forKey: "repeats")
        aCoder.encode(repeatCount, forKey: "repeatCount")
        aCoder.encode(numberCompleted, forKey: "numberCompleted")
        aCoder.encode(dueDate, forKey: "dueDate")
    }
    
    func copy(with zone: NSZone?) -> Any {
        let item = TodoItem(id: id, name: name, position: position)
        item.points = points
        item.minutes = minutes
        item.completed = completed
        item.repeats = repeats
        item.repeatCount = repeatCount
        item.numberCompleted = numberCompleted
        item.dueDate = dueDate
        return item
    }
    
    func updateFromItem(_ otherItem: TodoItem) -> Void {
        name = otherItem.name
        points = otherItem.points
        minutes = otherItem.minutes
        position = otherItem.position
        repeats = otherItem.repeats
        repeatCount = otherItem.repeatCount
        dueDate = otherItem.dueDate
    }
}

func ==(left: TodoItem, right: TodoItem) -> Bool {
    return left.id == right.id
}
