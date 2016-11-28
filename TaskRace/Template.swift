//
//  Template.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class Template: NSObject, NSCoding {
    let id: String
    var name: String
    var listID: String?
    var templateDays: TemplateDays
    var position: Int
    var anytime: Bool
    
    init(name: String, position: Int) {
        id = UUID().uuidString
        self.name = name
        self.listID = nil
        templateDays = .None
        self.position = position
        anytime = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        listID = aDecoder.decodeObject(forKey: "listID") as? String
        templateDays = TemplateDays(UInt(aDecoder.decodeInteger(forKey: "templateDays")))
        position = aDecoder.decodeInteger(forKey: "position")
        anytime = aDecoder.decodeBool(forKey: "anytime")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(listID, forKey: "listID")
        aCoder.encode(Int(templateDays.rawValue), forKey: "templateDays")
        aCoder.encode(position, forKey: "position")
        aCoder.encode(anytime, forKey: "anytime")
    }
}

func ==(lhs: Template, rhs: Template) -> Bool {
    return lhs.id == rhs.id
}
