//
//  UserDataController.swift
//  Todo
//
//  Created by Heather Shelley on 10/23/14.
//  Copyright (c) 2014 Mine. All rights reserved.
//

import Foundation

struct UserDataController {
    private static let sharedInstance = UserDataController()
    let database: YapDatabase
    let connection: YapDatabaseConnection
    
    init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingPathComponent("data")
        database = YapDatabase(path: dbPath)
        connection = database.newConnection()
    }
    
    func sharedController() -> UserDataController {
        return UserDataController.sharedInstance
    }
}
