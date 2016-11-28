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
private let calendar = Calendar(identifier: Calendar.Identifier.gregorian)

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
    
    var date: Foundation.Date {
        get {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return calendar.date(from: components)!
        }
    }
    
    override init() {
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday], from: Foundation.Date())
        year = components.year!
        month = components.month!
        day = components.day!
        dayOfWeek = TemplateDays(dayOfWeek: components.weekday!)
    }
    
    init(date: Foundation.Date) {
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday], from: date)
        year = components.year!
        month = components.month!
        day = components.day!
        dayOfWeek = TemplateDays(dayOfWeek: components.weekday!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        year = aDecoder.decodeInteger(forKey: "year")
        month = aDecoder.decodeInteger(forKey: "month")
        day = aDecoder.decodeInteger(forKey: "day")
        dayOfWeek = TemplateDays(UInt(aDecoder.decodeInteger(forKey: "dayOfWeek")))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(year, forKey: "year")
        aCoder.encode(month, forKey: "month")
        aCoder.encode(day, forKey: "day")
        aCoder.encode(Int(dayOfWeek.rawValue), forKey: "dayOfWeek")
    }
    
    func dateByAddingDays(_ days: Int) -> Date {
        var components = DateComponents()
        components.day = days
        return Date(date: (calendar as NSCalendar).date(byAdding: components, to: date, options: NSCalendar.Options(rawValue: 0))!)
    }
    
    func numberOfDaysUntilDate(_ toDate: Date) -> Int {
        return (calendar as NSCalendar).components(NSCalendar.Unit.day, from: date, to: toDate.date, options: NSCalendar.Options(rawValue: 0)).day!
    }
    
    // MARK: - DebugPrintable
    
    override var debugDescription: String {
        get {
            return string
        }
    }
    
}
