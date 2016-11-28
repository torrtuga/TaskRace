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
    var listID: String
    
    init(date: Date, listID: String) {
        id = UUID().uuidString
        self.date = date
        self.listID = listID
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        date = aDecoder.decodeObject(forKey: "date") as! Date
        listID = aDecoder.decodeObject(forKey: "listID") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(listID, forKey: "listID")
    }
}
