//
//  List.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class List: NSObject, NSCoding {
    let id: String
    var items: [TodoItem]
    
    override init() {
        id = NSUUID().UUIDString
        items = []
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        items = aDecoder.decodeObjectForKey("items") as! [TodoItem]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(items, forKey: "items")
    }
}