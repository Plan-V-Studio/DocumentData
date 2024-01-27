//
//  StorageNameMacro.swift
//  
//
//  Created by Akivili Collindort on 2023/12/6.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct StorageNameMacro { }

extension StorageNameMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var isErrorOccurred = false
        guard let decl = declaration.as(VariableDeclSyntax.self) else {
            throw PersistedModelError.incorrectSyntaxStructure(declaration, VariableDeclSyntax.self)
        }
        
        // check the "let" keyword
        // compatiable for fix-it
        if decl.bindingSpecifier.text != "let" {
            isErrorOccurred = true
            context.diagnose(
                Diagnostic(
                    node: decl.bindingSpecifier,
                    message: DiagMsg(
                        message: String(describing: PersistedModelError.onlyAvailableForConstant),
                        diagnosticID: MessageID(domain: "DocumentData", id: "Error.onlyAvailableForConstant"),
                        severity: .error
                    ),
                    fixIt: FixIt(
                        message: FixitMsg(
                            message: #"Use "let" instead of "var"."#,
                            fixItID: MessageID(domain: "DocumentData", id: "Fixit.onlyAvailableForConstant")
                        ),
                        changes: [
                            .replace(
                                oldNode: Syntax(decl.bindingSpecifier), newNode: Syntax(TokenSyntax(stringLiteral: "let"))
                            )
                        ]
                    )
                )
            )
        }
        
        // check the "static" keyword
        if !decl.modifiers.contains(where: { $0.name.text == "static" }) {
            isErrorOccurred = true
            context.addDiagnostics(
                from: PersistedModelError.onlyAvailableForStaticProperty,
                node: decl.modifiers
            )
        }
        
        guard let initializer = decl.bindings.first?.as(PatternBindingSyntax.self)?.initializer else {
            context.addDiagnostics(from: PersistedModelError.storageNoInitializer, node: decl.bindings)
            return []
        }
        
        if !isErrorOccurred {
            return [
            """
            @_PersistedIgnored private static let _$persistedDocumentName = "\(raw: initializer.value.as(StringLiteralExprSyntax.self)!.segments.description).storage.plist"
            """
            ]
        } else {
            return []
        }
    }
}
