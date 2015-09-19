//
//  Date.swift
//  Todo
//
//  Created by Heather Shelley on 11/4/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

func == (left: Date, right: Date) -> Bool {
    return left.string == right.string
}

func < (left: Date, right: Date) -> Bool {
    return left.string < right.string
}

// The Gregorian calendar should always be available; if not, the app is hosed anyway
private let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

class Date: NSObject, Comparable, CustomDebugStringConvertible, NSCoding {
    let year: Int
    let month: Int
    let day: Int
    let dayOfWeek: TemplateDays
    
    var string: String {
        get {
            return String(format: "%04d-%02d-%02d", arguments: [year, month, day])
        }
    }
    
    var date: NSDate {
        get {
            let components = NSDateComponents()
            components.year = year
            components.month = month
            components.day = day
            return calendar.dateFromComponents(components)!
        }
    }
    
    override init() {
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday], fromDate: NSDate())
        year = components.year
        month = components.month
        day = components.day
        dayOfWeek = TemplateDays(dayOfWeek: components.weekday)
    }
    
    init(date: NSDate) {
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday], fromDate: date)
        year = components.year
        month = components.month
        day = components.day
        dayOfWeek = TemplateDays(dayOfWeek: components.weekday)
    }
    
    required init?(coder aDecoder: NSCoder) {
        year = aDecoder.decodeIntegerForKey("year")
        month = aDecoder.decodeIntegerForKey("month")
        day = aDecoder.decodeIntegerForKey("day")
        dayOfWeek = TemplateDays(UInt(aDecoder.decodeIntegerForKey("dayOfWeek")))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(year, forKey: "year")
        aCoder.encodeInteger(month, forKey: "month")
        aCoder.encodeInteger(day, forKey: "day")
        aCoder.encodeInteger(Int(dayOfWeek.rawValue), forKey: "dayOfWeek")
    }
    
    func dateByAddingDays(days: Int) -> Date {
        let components = NSDateComponents()
        components.day = days
        return Date(date: calendar.dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))!)
    }
    
    func numberOfDaysUntilDate(toDate: Date) -> Int {
        return calendar.components(NSCalendarUnit.Day, fromDate: date, toDate: toDate.date, options: NSCalendarOptions(rawValue: 0)).day
    }
    
    // MARK: - DebugPrintable
    
    override var debugDescription: String {
        get {
            return string
        }
    }
    
}
