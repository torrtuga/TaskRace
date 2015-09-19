//
//  StoreItem.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class StoreItem: NSObject, NSCoding {
    let id: String
    var name: String
    var points: Int
    var purchased: Bool
    var position: Int
    var repeats: Bool
    
    init(name: String, position: Int) {
        id = NSUUID().UUIDString
        self.name = name
        points = 0
        purchased = false
        self.position = position
        repeats = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        name = aDecoder.decodeObjectForKey("name") as! String
        points = aDecoder.decodeIntegerForKey("points")
        purchased = aDecoder.decodeBoolForKey("purchased")
        position = aDecoder.decodeIntegerForKey("position")
        repeats = aDecoder.decodeBoolForKey("repeats")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(points, forKey: "points")
        aCoder.encodeBool(purchased, forKey: "purchased")
        aCoder.encodeInteger(position, forKey: "position")
        aCoder.encodeBool(repeats, forKey: "repeats")
    }
}