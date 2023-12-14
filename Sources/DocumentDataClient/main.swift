import DocumentData
import Foundation
import DocumentDataMacros

// MARK: - Expasion

@PersistedModel
class StoringData {
    var isFirstToggleOpen: Bool
    var textFieldText: String
    
    @PersistedIgnored
    var ignoredButObservedToggle: Bool
    
    @StorageName
    var storeName = "Default"
    
    init(isFirstToggleOpen: Bool, textFieldText: String, ignoredButObservedToggle: Bool) {
        self.isFirstToggleOpen = isFirstToggleOpen
        self.textFieldText = textFieldText
        self.ignoredButObservedToggle = ignoredButObservedToggle
    }
}
