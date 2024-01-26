//
//  PersistedModelError.swift
//
//
//  Created by Akivili Collindort on 2023/12/4.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Error that expading DocumentData macros may occur.
///
enum PersistedModelError: CustomStringConvertible, Error {
    /// This error may occurred when `@PersistedModel`'s applied property is not `class`.
    case unavaliableApplyingType
    
    /// This error may occurred when applied class structure was incorrect.
    case incorrectClassStructure(syntax: DeclGroupSyntax)
    
    /// This error may occurred when variable's property attribute was incorrect.
    case incorrectPropertyAttributeStructure
    
    /// This error may occurred when code syntax converting incorrect.
    case incorrectSyntaxStructure(SyntaxProtocol, SyntaxProtocol.Type)
    
    /// This error may occurred when attached member is not variable.
    case onlyAvailableForVariable
    
    /// This error may occurred when macro expanding, any unexpected expansion and syntax may occur this error.
    case errorOccurredWhileExpanding(functionName: String)
    
    /// This error may occurred when @StorageName macro do not attached on a variable which have initializer.
    case storageNoInitializer
    
    /// This error may occurred when macro required it property declared as a constant (let syntax).
    case onlyAvailableForConstant
    
    /// This error may occurred when macro required it property declared as a static property.
    case onlyAvailableForStaticProperty
    
    var description: String {
        switch self {
        case .unavaliableApplyingType:
            return "@PersistedModel can applied on class property."
        case .incorrectClassStructure(let decl):
            return "This class structure was incorrect. \n\(decl)"
        case .incorrectPropertyAttributeStructure:
            return "The structure in this class was incorrect."
        case .incorrectSyntaxStructure(let syntax, let syntaxtype):
            return "This syntax cannot transform to \(syntaxtype). \n\(syntax.description)"
        case .onlyAvailableForVariable:
            return "@PresistedProperty can only applied on variable declarations."
        case .errorOccurredWhileExpanding(let function):
            return "Some error occurred while expanding macros. Occurred at \(function)"
        case .storageNoInitializer:
            return "The property modified by the @StorageName macro requires an initializer."
        case .onlyAvailableForConstant:
            return "@StorageName only available for \"let\" property."
        case .onlyAvailableForStaticProperty:
            return "@StorageName only available for static property."
        }
    }
}
