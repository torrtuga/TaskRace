//
//  Template.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

struct TemplateDays: RawOptionSetType {
    typealias RawValue = UInt
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    static var allZeros: TemplateDays { return self(0) }
    static func fromMask(raw: UInt) -> TemplateDays { return self(raw) }
    var rawValue: UInt { return self.value }
    
    static var None: TemplateDays { return self(0) }
    static var Monday: TemplateDays { return TemplateDays(1 << 0) }
    static var Tuesday: TemplateDays { return TemplateDays(1 << 1) }
    static var WednesDay: TemplateDays { return TemplateDays(1 << 2) }
    static var Thursday: TemplateDays { return TemplateDays(1 << 3) }
    static var Friday: TemplateDays { return TemplateDays(1 << 4) }
    static var Saturday: TemplateDays { return TemplateDays(1 << 5) }
    static var Sunday: TemplateDays { return TemplateDays(1 << 6) }
}

class Template: NSObject, NSCoding {
    let id: String
    let name: String
    let listID: String
    let templateDays: TemplateDays
    let position: Int
    
    init(name: String, position: Int) {
        id = NSUUID().UUIDString
        self.name = name
        self.listID = UserDataController.sharedController().createEmptyList().id
        templateDays = .None
        self.position = position
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as String
        name = aDecoder.decodeObjectForKey("name") as String
        listID = aDecoder.decodeObjectForKey("listID") as String
        templateDays = TemplateDays(UInt(aDecoder.decodeIntegerForKey("templateDays")))
        position = aDecoder.decodeIntegerForKey("position")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(listID, forKey: "listID")
        aCoder.encodeInteger(Int(templateDays.rawValue), forKey: "templateDays")
        aCoder.encodeInteger(position, forKey: "position")
    }
}
