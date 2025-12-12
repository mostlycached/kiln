import Foundation
import SwiftData

/// The 6 phases of the Kiln process
enum KilnPhase: Int, CaseIterable, Identifiable, Hashable, Codable {
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
@Model
final class KilnSession {
    var anchorName: String
    var startingForm: String
    var createdAt: Date
    var isComplete: Bool
    
    // Store reflections as individual properties (SwiftData doesn't support Dictionary)
    var reflection0: String  // enumeratedBed
    var reflection1: String  // anchorHeating
    var reflection2: String  // emptyHeat
    var reflection3: String  // formTying
    var reflection4: String  // formSettling
    var reflection5: String  // observation
    
    var roomName: String
    var roomSpirit: String
    
    // Timer tracking for Empty Heat phase
    var emptyHeatDuration: TimeInterval = 0
    
    init(
        anchorName: String = "Anxiety Navigation",
        startingForm: String = "The WiFi Fails",
        createdAt: Date = Date(),
        isComplete: Bool = false
    ) {
        self.anchorName = anchorName
        self.startingForm = startingForm
        self.createdAt = createdAt
        self.isComplete = isComplete
        self.reflection0 = ""
        self.reflection1 = ""
        self.reflection2 = ""
        self.reflection3 = ""
        self.reflection4 = ""
        self.reflection5 = ""
        self.roomName = ""
        self.roomSpirit = ""
        self.emptyHeatDuration = 0
    }
    
    // Helper to get/set reflection by phase
    func reflection(for phase: KilnPhase) -> String {
        switch phase {
        case .enumeratedBed: return reflection0
        case .anchorHeating: return reflection1
        case .emptyHeat: return reflection2
        case .formTying: return reflection3
        case .formSettling: return reflection4
        case .observation: return reflection5
        }
    }
    
    func setReflection(_ text: String, for phase: KilnPhase) {
        switch phase {
        case .enumeratedBed: reflection0 = text
        case .anchorHeating: reflection1 = text
        case .emptyHeat: reflection2 = text
        case .formTying: reflection3 = text
        case .formSettling: reflection4 = text
        case .observation: reflection5 = text
        }
    }
}
