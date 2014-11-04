//
//  StoreItem.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class StoreItem: NSCoding {
    let id: String
    let points: Int
    let purchased: Bool
    
    init(points: Int) {
        id = NSUUID().UUIDString
        self.points = points
        purchased = false
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as String
        points = aDecoder.decodeIntegerForKey("points")
        purchased = aDecoder.decodeBoolForKey("purchased")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeInteger(points, forKey: "points")
        aCoder.encodeBool(purchased, forKey: "purchased")
    }
}