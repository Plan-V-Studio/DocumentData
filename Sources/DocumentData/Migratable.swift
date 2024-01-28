//
//  Migratable.swift
//
//
//  Created by Akivili Collindort on 2024/1/29.
//

import Foundation

protocol Migratable: AnyObject {
    static func migrate()
    
    static var shouldMigrate: Bool { get }
}
