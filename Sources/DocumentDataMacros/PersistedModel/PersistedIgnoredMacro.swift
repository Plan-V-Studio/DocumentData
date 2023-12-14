//
//  PersistedIgnoredMacro.swift
//
//
//  Created by Akivili Collindort on 2023/12/4.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PersistedIgnoredMacro { }

extension PersistedIgnoredMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ignore this property
        return []
    }
}
