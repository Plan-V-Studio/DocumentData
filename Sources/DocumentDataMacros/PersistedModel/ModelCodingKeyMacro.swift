//
//  ModelCodingKeyMacro.swift
//
//
//  Created by Akivili Collindort on 2024/1/28.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ModelCodingKeyMacro { }

extension ModelCodingKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TODO: Implementation
        guard let decl = declaration.as(EnumDeclSyntax.self) else {
            // TODO: Error handling
            return []
        }
        
        guard let inheritanceClause = decl.inheritanceClause else {
            // TODO: Error handling
            return []
        }
        
        // check whether the enum comforms to CodingKey
        guard inheritanceClause.inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "CodingKey" }) else {
            // TODO: Error handling
            return []
        }
        
        let members = decl.memberBlock.members
        
        
        return [
            """
            enum _$PersistedCodingKeys\(raw: inheritanceClause.description){
            \(raw: try memberTranslator(members))
            }
            """
        ]
    }
    
    private static func memberTranslator(_ members: MemberBlockItemListSyntax) throws -> String {
        var result = [String]()
        
        // extract key and name from syntax
        try members.forEach {
            guard let enumCase = $0.decl.as(EnumCaseDeclSyntax.self) else {
                // TODO: Error handling
                throw PersistedModelError.errorOccurredWhileExpanding(functionName: "memberTranslator")
            }
            
            try enumCase.elements.forEach { caseElement in
                guard let literalExpr = caseElement.rawValue?.value.description else {
                    throw PersistedModelError.errorOccurredWhileExpanding(functionName: "memberTranslator")
                }
                
                result.append(
                    "case _\(caseElement.name.text) = \(literalExpr)"
                )
            }
        }
        
        result = result.map { "    " + $0 }
        return result.joined(separator: "\n")
    }
}
