import Foundation

/// The 6 phases of the Kiln process
enum KilnPhase: Int, CaseIterable, Identifiable, Hashable {
    case enumeratedBed = 0
    case anchorHeating = 1
    case emptyHeat = 2
    case formTying = 3
    case formSettling = 4
    case observation = 5
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .enumeratedBed: return "1. Enumerated Bed of Anchors"
        case .anchorHeating: return "2. Anchor Heating"
        case .emptyHeat: return "3. Empty Heat Period"
        case .formTying: return "4. Form Tying Mode"
        case .formSettling: return "5. Form Settling Mode"
        case .observation: return "6. Observation & Journaling"
        }
    }
    
    var prompt: String {
        switch self {
        case .enumeratedBed:
            return "What desire is this habit serving? Describe the current 'room' you're in."
        case .anchorHeating:
            return "How will you dissolve this form? What constraint or defamiliarization can you apply?"
        case .emptyHeat:
            return "Sit in the gap. What urges arise? What does the formlessness feel like?"
        case .formTying:
            return "What adjacent possibilities emerge? What new connections can you make?"
        case .formSettling:
            return "What is the new form crystallizing into? Give it a name and a ritual."
        case .observation:
            return "What is the spirit of this new room? What trace does it leave?"
        }
    }
}

/// A single session through the Kiln process
struct KilnSession {
    let anchor: String
    let startingForm: String
    var reflections: [KilnPhase: String] = [:]
    var roomName: String = ""
    var roomSpirit: String = ""
    
    static let defaultAnchor = "Anxiety Navigation"
    static let defaultForm = "The WiFi Fails"
    
    static func createDefault() -> KilnSession {
        KilnSession(anchor: defaultAnchor, startingForm: defaultForm)
    }
}
