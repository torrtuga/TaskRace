//
//  TodoItem.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class TodoItem: NSObject, NSCoding {
    let id: String
    var name: String
    var points: Int
    var minutes: Int
    var completed: Bool
    var position: Int
    
    init(name: String, position: Int) {
        id = NSUUID().UUIDString
        self.name = name
        self.points = 0
        self.minutes = 0
        completed = false
        self.position = position
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as String
        name = aDecoder.decodeObjectForKey("name") as String
        points = aDecoder.decodeIntegerForKey("points")
        minutes = aDecoder.decodeIntegerForKey("minutes")
        completed = aDecoder.decodeBoolForKey("completed")
        position = aDecoder.decodeIntegerForKey("position")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(points, forKey: "points")
        aCoder.encodeInteger(minutes, forKey: "minutes")
        aCoder.encodeBool(completed, forKey: "completed")
        aCoder.encodeInteger(position, forKey: "position")
    }
}