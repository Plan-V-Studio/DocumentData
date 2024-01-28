//
//  DocumentPersistedModel.swift
//
//
//  Created by Akivili Collindort on 2023/12/6.
//

import Foundation

/// Sign for the persistence model.
///
/// ## Discussion
///
///- Important: This protocol is only used to tag the DocumentData. You should always use ``PersistedModel()`` macro to automatically make class conform to this protocol.
public protocol DocumentPersistedModel: AnyObject {
    /// Returns the currently stored persistent file.
    ///
    /// - Important: Before invoking this method, it is important that the ``isPersisted`` method is invoked to check whether persistent files exist.
    static var `default`: Self { get }
    
    /// Check whether the data is persisted.
    static var isPersisted: Bool { get }
    
    /// Delete the persistence file from storage.
    static func delete() throws
}
