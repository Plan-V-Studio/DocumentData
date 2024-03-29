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
        guard let decl = declaration.as(EnumDeclSyntax.self) else {
            throw PersistedModelError.onlyAvailableForEnum(macroName: "ModelCodingKey")
        }
        
        guard let inheritanceClause = decl.inheritanceClause else {
            throw PersistedModelError.cannotFindInheritanceClause
        }
        
        // check whether the enum conforms to CodingKey
        guard inheritanceClause.inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "CodingKey" }) else {
            throw PersistedModelError.notConformsToCodingKey
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
