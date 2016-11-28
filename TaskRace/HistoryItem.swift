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
    let dateCompleted: Foundation.Date
    let name: String
    let points: Int
    let numberCompleted: Int
    
    fileprivate init(id: String, name: String, points: Int, dateCompleted: Foundation.Date, numberCompleted: Int) {
        self.id = id
        self.name = name
        self.points = points
        self.dateCompleted = dateCompleted
        self.numberCompleted = numberCompleted
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? HistoryItem {
            return id == other.id
        }
        
        return false
    }
    
    convenience init(name: String, points: Int, dateCompleted: Foundation.Date, numberCompleted: Int) {
        self.init(id: UUID().uuidString, name: name, points: points, dateCompleted: dateCompleted, numberCompleted: numberCompleted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        points = aDecoder.decodeInteger(forKey: "points")
        dateCompleted = aDecoder.decodeObject(forKey: "dateCompleted") as! Foundation.Date
        numberCompleted = aDecoder.decodeInteger(forKey: "numberCompleted")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(points, forKey: "points")
        aCoder.encode(dateCompleted, forKey: "dateCompleted")
        aCoder.encode(numberCompleted, forKey: "numberCompleted")
    }
}
