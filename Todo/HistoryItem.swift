//
//  HistoryItem.swift
//  Todo
//
//  Created by Heather Shelley on 1/1/15.
//  Copyright (c) 2015 Mine. All rights reserved.
//

import Foundation

class HistoryItem: NSObject, NSCoding {
    let id: String
    let dateCompleted: NSDate
    let name: String
    let points: Int
    let numberCompleted: Int
    
    private init(id: String, name: String, points: Int, dateCompleted: NSDate, numberCompleted: Int) {
        self.id = id
        self.name = name
        self.points = points
        self.dateCompleted = dateCompleted
        self.numberCompleted = numberCompleted
    }
    
    convenience init(name: String, points: Int, dateCompleted: NSDate, numberCompleted: Int) {
        self.init(id: NSUUID().UUIDString, name: name, points: points, dateCompleted: dateCompleted, numberCompleted: numberCompleted)
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as String
        name = aDecoder.decodeObjectForKey("name") as String
        points = aDecoder.decodeIntegerForKey("points")
        dateCompleted = aDecoder.decodeObjectForKey("dateCompleted") as NSDate
        numberCompleted = aDecoder.decodeIntegerForKey("numberCompleted")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(points, forKey: "points")
        aCoder.encodeObject(dateCompleted, forKey: "dateCompleted")
        aCoder.encodeInteger(numberCompleted, forKey: "numberCompleted")
    }
}
