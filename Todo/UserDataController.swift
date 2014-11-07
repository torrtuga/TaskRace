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
    
    static func sharedController() -> UserDataController {
        return UserDataController.sharedInstance
    }
    
    init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingPathComponent("data")
        NSFileManager.defaultManager().createDirectoryAtPath(dbPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        database = YapDatabase(path: dbPath)
        connection = database.newConnection()
    }
    
    func allTemplates() -> [Template] {
        var templates: [Template] = []
        self.connection.readWithBlock() { transaction in
            transaction.enumerateKeysAndObjectsInCollection("templates") { key, object, _ in
                if let template = object as? Template {
                    templates.append(template)
                }
            }
        }
        
        return sorted(templates) { $0.position < $1.position }
    }
    
    func addOrUpdateTemplate(template: Template) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.setObject(template, forKey: template.id, inCollection: "templates")
        }
    }
    
    func updateTemplates(templates: [Template]) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            for template in templates {
                transaction.setObject(template, forKey: template.id, inCollection: "templates")
            }
        }
    }
    
    func removeTemplate(template: Template) -> Void {
        self.connection.readWriteWithBlock() { transaction in
            transaction.removeObjectForKey(template.id, inCollection: "templates")
        }
    }
    
    func createEmptyList() -> List {
        let list = List()
        self.connection.readWriteWithBlock() { transaction in
            transaction.setObject(list, forKey: list.id, inCollection: "lists")
        }
        
        return list
    }
}
