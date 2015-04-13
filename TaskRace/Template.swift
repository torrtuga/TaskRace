//
//  Template.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

class Template: NSObject, NSCoding, Equatable {
    let id: String
    var name: String
    var listID: String?
    var templateDays: TemplateDays
    var position: Int
    var anytime: Bool
    
    init(name: String, position: Int) {
        id = NSUUID().UUIDString
        self.name = name
        self.listID = nil
        templateDays = .None
        self.position = position
        anytime = false
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        name = aDecoder.decodeObjectForKey("name") as! String
        listID = aDecoder.decodeObjectForKey("listID") as? String
        templateDays = TemplateDays(UInt(aDecoder.decodeIntegerForKey("templateDays")))
        position = aDecoder.decodeIntegerForKey("position")
        anytime = aDecoder.decodeBoolForKey("anytime")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(listID, forKey: "listID")
        aCoder.encodeInteger(Int(templateDays.rawValue), forKey: "templateDays")
        aCoder.encodeInteger(position, forKey: "position")
        aCoder.encodeBool(anytime, forKey: "anytime")
    }
}

func ==(lhs: Template, rhs: Template) -> Bool {
    return lhs.id == rhs.id
}
