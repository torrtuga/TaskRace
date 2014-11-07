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
private let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!

class Date: NSObject, Comparable, DebugPrintable, NSCoding {
    let year: Int
    let month: Int
    let day: Int
    
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
        let components = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
        year = components.year
        month = components.month
        day = components.day
    }
    
    init(date: NSDate) {
        let components = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: date)
        year = components.year
        month = components.month
        day = components.day
    }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    init(_ string: String) {
        let scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = nil
        
        var year: Int = 0
        if !scanner.scanInteger(&year) || year < 0 {
            assert(false, "Failed to parse year")
        }
        self.year = year
        
        if !scanner.scanString("-", intoString: nil) {
            assert(false, "Failed to parse dash")
        }
        
        var month: Int = 0
        if !scanner.scanInteger(&month) || month < 0 {
            assert(false, "Failed to parse month")
        }
        self.month = month
        
        if !scanner.scanString("-", intoString: nil) {
            assert(false, "Failed to parse dash")
        }
        
        var day: Int = 0
        if !scanner.scanInteger(&day) || day < 0 {
            assert(false, "Failed to parse day")
        }
        self.day = day
    }
    
    required init(coder aDecoder: NSCoder) {
        year = aDecoder.decodeIntegerForKey("year")
        month = aDecoder.decodeIntegerForKey("month")
        day = aDecoder.decodeIntegerForKey("day")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(year, forKey: "year")
        aCoder.encodeInteger(month, forKey: "month")
        aCoder.encodeInteger(day, forKey: "day")
    }
    
    func dateByAddingDays(days: Int) -> Date {
        let components = NSDateComponents()
        components.day = days
        return Date(date: calendar.dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))!)
    }
    
    func numberOfDaysUntilDate(toDate: Date) -> Int {
        return calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: date, toDate: toDate.date, options: NSCalendarOptions(0)).day
    }
    
    // MARK: - DebugPrintable
    
    override var debugDescription: String {
        get {
            return string
        }
    }
    
}
