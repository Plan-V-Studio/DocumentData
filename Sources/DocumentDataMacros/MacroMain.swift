//
//  main.swift
//
//
//  Created by Akivili Collindort on 2023/12/3.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DocumentDataPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PersistedModelMacro.self,
        PersistedPropertyMacro.self,
        PersistedIgnoredMacro.self,
        ObservationPersistedIgnoredMacro.self,
        StorageNameMacro.self,
        ModelCodingKeyMacro.self,
    ]
}
