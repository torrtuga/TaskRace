//
//  TodoItem.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class TodoItem: NSObject, NSCoding, NSCopying, Equatable {
    let id: String
    var name: String
    var points: Int
    var minutes: Int
    var completed: Bool
    var position: Int
    var repeats: Bool
    var repeatCount: Int
    var numberCompleted: Int
    
    private init(id: String, name: String, position: Int) {
        self.id = id
        self.name = name
        points = 0
        minutes = 0
        completed = false
        self.position = position
        repeats = false
        repeatCount = 0
        numberCompleted = 0
    }
    
    convenience init(name: String, position: Int) {
        self.init(id: NSUUID().UUIDString, name: name, position: position)
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as String
        name = aDecoder.decodeObjectForKey("name") as String
        points = aDecoder.decodeIntegerForKey("points")
        minutes = aDecoder.decodeIntegerForKey("minutes")
        completed = aDecoder.decodeBoolForKey("completed")
        position = aDecoder.decodeIntegerForKey("position")
        repeats = aDecoder.decodeBoolForKey("repeats")
        repeatCount = aDecoder.decodeIntegerForKey("repeatCount")
        numberCompleted = aDecoder.decodeIntegerForKey("numberCompleted")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(points, forKey: "points")
        aCoder.encodeInteger(minutes, forKey: "minutes")
        aCoder.encodeBool(completed, forKey: "completed")
        aCoder.encodeInteger(position, forKey: "position")
        aCoder.encodeBool(repeats, forKey: "repeats")
        aCoder.encodeInteger(repeatCount, forKey: "repeatCount")
        aCoder.encodeInteger(numberCompleted, forKey: "numberCompleted")
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let item = TodoItem(id: id, name: name, position: position)
        item.points = points
        item.minutes = minutes
        item.completed = completed
        item.repeats = repeats
        item.repeatCount = repeatCount
        item.numberCompleted = numberCompleted
        return item
    }
    
    func updateFromItem(otherItem: TodoItem) -> Void {
        name = otherItem.name
        points = otherItem.points
        minutes = otherItem.minutes
        position = otherItem.position
        repeats = otherItem.repeats
        repeatCount = otherItem.repeatCount
        numberCompleted = otherItem.numberCompleted
    }
}

func ==(left: TodoItem, right: TodoItem) -> Bool {
    return left.id == right.id
}