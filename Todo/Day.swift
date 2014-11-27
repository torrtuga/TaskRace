//
//  Day.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class Day: NSObject, NSCoding {
    let id: String
    let date: Date
    var listID: String?
    
    init(date: Date) {
        id = NSUUID().UUIDString
        self.date = date
        listID = nil
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as String
        date = aDecoder.decodeObjectForKey("date") as Date
        listID = aDecoder.decodeObjectForKey("listID") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(listID, forKey: "listID")
    }
}
