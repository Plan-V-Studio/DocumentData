//
//  Diagnostic.swift
//
//
//  Created by Akivili Collindort on 2024/1/27.
//

import Foundation
import SwiftDiagnostics

struct DiagMsg: DiagnosticMessage {
    var message: String
    
    var diagnosticID: MessageID
    
    var severity: DiagnosticSeverity
}

struct FixitMsg: FixItMessage {
    var message: String
    
    var fixItID: MessageID
}
