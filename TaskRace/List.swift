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
        id = UUID().uuidString
        items = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        items = aDecoder.decodeObject(forKey: "items") as! [TodoItem]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(items, forKey: "items")
    }
}
