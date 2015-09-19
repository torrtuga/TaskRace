//
//  TemplateDays.swift
//  Todo
//
//  Created by Heather Shelley on 11/22/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

struct TemplateDays: OptionSetType, BooleanType {
    typealias RawValue = UInt
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    init(dayOfWeek: Int) { self.value = 1 << UInt(dayOfWeek - 1) }
    static var allZeros: TemplateDays { return self.init(0) }
    static func fromMask(raw: UInt) -> TemplateDays { return self.init(raw) }
    var rawValue: UInt { return self.value }
    var boolValue: Bool { return value > 0 }
    var stringValue: String {
        switch TemplateDays(value) {
        case TemplateDays.None:
            return "None"
        case TemplateDays.Sunday:
            return "Sunday"
        case TemplateDays.Monday:
            return "Monday"
        case TemplateDays.Tuesday:
            return "Tuesday"
        case TemplateDays.Wednesday:
            return "Wednesday"
        case TemplateDays.Thursday:
            return "Thursday"
        case TemplateDays.Friday:
            return "Friday"
        case TemplateDays.Saturday:
            return "Saturday"
        default:
            return "None"
        }
    }
    
    var shortStringValue: String {
        switch TemplateDays(value) {
        case TemplateDays.None:
            return "None"
        case TemplateDays.Sunday:
            return "Su"
        case TemplateDays.Monday:
            return "Mo"
        case TemplateDays.Tuesday:
            return "Tu"
        case TemplateDays.Wednesday:
            return "We"
        case TemplateDays.Thursday:
            return "Th"
        case TemplateDays.Friday:
            return "Fr"
        case TemplateDays.Saturday:
            return "Sa"
        default:
            return "None"
        }
    }
    
    static var None: TemplateDays { return self.init(0) }
    static var Sunday: TemplateDays { return TemplateDays(1 << 0) }
    static var Monday: TemplateDays { return TemplateDays(1 << 1) }
    static var Tuesday: TemplateDays { return TemplateDays(1 << 2) }
    static var Wednesday: TemplateDays { return TemplateDays(1 << 3) }
    static var Thursday: TemplateDays { return TemplateDays(1 << 4) }
    static var Friday: TemplateDays { return TemplateDays(1 << 5) }
    static var Saturday: TemplateDays { return TemplateDays(1 << 6) }
}

func daysStringFromTemplateDays(days: TemplateDays) -> String {
    var val = ""
    var found = 0
    if days.intersect(TemplateDays.Sunday) {
        val += "Su"
        found += 1
    }
    if days.intersect(TemplateDays.Monday) {
        if found == 0 {
            if !val.isEmpty {
                val += ","
            }
            val += "Mo"
        }
        found += 1
    } else {
        found = 0
    }
    if days.intersect(TemplateDays.Tuesday) {
        if found == 0 {
            if !val.isEmpty {
                val += ","
            }
            val += "Tu"
        }
        found += 1
    } else {
        if found > 1 {
            val += "-Mo"
        }
        found = 0
    }
    if days.intersect(TemplateDays.Wednesday) {
        if found == 0 {
            if !val.isEmpty {
                val += ","
            }
            val += "We"
        }
        found += 1
    } else {
        if found > 1 {
            val += "-Tu"
        }
        found = 0
    }
    if days.intersect(TemplateDays.Thursday) {
        if found == 0 {
            if !val.isEmpty {
                val += ","
            }
            val += "Th"
        }
        found += 1
    } else {
        if found > 1 {
            val += "-We"
        }
        found = 0
    }
    if days.intersect(TemplateDays.Friday) {
        if found == 0 {
            if !val.isEmpty {
                val += ","
            }
            val += "Fr"
        }
        found += 1
    } else {
        if found > 1 {
            val += "-Th"
        }
        found = 0
    }
    if days.intersect(TemplateDays.Saturday) {
        if found == 0 {
            if !val.isEmpty {
                val += ","
            }
            val += "Sa"
        }
        found += 1
    } else {
        if found > 1 {
            val += "-Fr"
        }
        found = 0
    }
    
    if found > 1 {
        val += "-Sa"
    }
    
    return val
}