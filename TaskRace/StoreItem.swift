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
        id = UUID().uuidString
        self.name = name
        points = 0
        purchased = false
        self.position = position
        repeats = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        points = aDecoder.decodeInteger(forKey: "points")
        purchased = aDecoder.decodeBool(forKey: "purchased")
        position = aDecoder.decodeInteger(forKey: "position")
        repeats = aDecoder.decodeBool(forKey: "repeats")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(points, forKey: "points")
        aCoder.encode(purchased, forKey: "purchased")
        aCoder.encode(position, forKey: "position")
        aCoder.encode(repeats, forKey: "repeats")
    }
}
