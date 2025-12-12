import Foundation
import SwiftData

/// A user-defined custom anchor
@Model
final class CustomAnchor {
    var name: String
    var anchorDescription: String
    var createdAt: Date
    
    // Store tentative forms as JSON-encoded string (SwiftData doesn't support arrays of structs directly)
    var tentativeFormsJSON: String
    
    init(name: String, description: String, tentativeForms: [TentativeFormData] = []) {
        self.name = name
        self.anchorDescription = description
        self.createdAt = Date()
        self.tentativeFormsJSON = Self.encodeForms(tentativeForms)
    }
    
    var tentativeForms: [TentativeFormData] {
        get { Self.decodeForms(tentativeFormsJSON) }
        set { tentativeFormsJSON = Self.encodeForms(newValue) }
    }
    
    private static func encodeForms(_ forms: [TentativeFormData]) -> String {
        guard let data = try? JSONEncoder().encode(forms),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }
    
    private static func decodeForms(_ json: String) -> [TentativeFormData] {
        guard let data = json.data(using: .utf8),
              let forms = try? JSONDecoder().decode([TentativeFormData].self, from: data) else {
            return []
        }
        return forms
    }
    
    /// Convert to an Anchor struct for use in session creation
    func toAnchor() -> Anchor {
        Anchor(
            id: "custom-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))",
            name: name,
            description: anchorDescription,
            tentativeForms: tentativeForms.map { form in
                Anchor.TentativeForm(context: form.context, formName: form.formName)
            }
        )
    }
}

/// Codable form data for JSON storage
struct TentativeFormData: Codable, Identifiable, Hashable {
    let id: UUID
    var context: String
    var formName: String
    
    init(context: String = "", formName: String = "") {
        self.id = UUID()
        self.context = context
        self.formName = formName
    }
}
