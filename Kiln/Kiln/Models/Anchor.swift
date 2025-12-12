import Foundation

/// An anchor represents a core human desire/drive that grounds experience
struct Anchor: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let tentativeForms: [TentativeForm]
    
    struct TentativeForm: Identifiable, Hashable {
        let id = UUID()
        let context: String  // "Coffee Shop" or "Subway"
        let formName: String
    }
}

/// The 14 anchors from THESIS.md
extension Anchor {
    static let allAnchors: [Anchor] = [
        Anchor(
            id: "order-seeking",
            name: "Order Seeking",
            description: "The drive to organize chaos and establish predictability.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Regular Club"),
                TentativeForm(context: "Coffee Shop", formName: "The Construction"),
                TentativeForm(context: "Subway", formName: "The Driver"),
                TentativeForm(context: "Subway", formName: "The First Day")
            ]
        ),
        Anchor(
            id: "anxiety-navigation",
            name: "Anxiety Navigation",
            description: "Moving through uncertainty and managing the friction of the world.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The WiFi Fails"),
                TentativeForm(context: "Coffee Shop", formName: "The Spill"),
                TentativeForm(context: "Subway", formName: "The Stalled Train"),
                TentativeForm(context: "Subway", formName: "The Packed Car")
            ]
        ),
        Anchor(
            id: "post-realization-clarity",
            name: "Post-Realization Clarity",
            description: "The calm, expansive state that follows understanding or epiphany.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Breakthrough"),
                TentativeForm(context: "Subway", formName: "The Last Day"),
                TentativeForm(context: "Subway", formName: "The Existentialist Commute")
            ]
        ),
        Anchor(
            id: "enclosement",
            name: "Enclosement",
            description: "The pleasure of containment and safety vs. the fear of entrapment.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Construction"),
                TentativeForm(context: "Subway", formName: "The Silent Car"),
                TentativeForm(context: "Subway", formName: "The Doors Closing")
            ]
        ),
        Anchor(
            id: "path-following",
            name: "Path Following",
            description: "The ease of the beaten track; surrendering to a pre-defined trajectory.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Too Long"),
                TentativeForm(context: "Subway", formName: "The Descent"),
                TentativeForm(context: "Subway", formName: "The Driver")
            ]
        ),
        Anchor(
            id: "horizon-seeking",
            name: "Horizon Seeking & Stasis",
            description: "The drive to look forward vs. the worship of the fixed line.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Music Changes"),
                TentativeForm(context: "Subway", formName: "The Dream Commute")
            ]
        ),
        Anchor(
            id: "controlled-ignorance",
            name: "Controlled Ignorance",
            description: "The pleasure of a filtered environment; ignoring noise to focus on signal.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Watcher"),
                TentativeForm(context: "Coffee Shop", formName: "The WiFi Fails"),
                TentativeForm(context: "Subway", formName: "The Silent Car")
            ]
        ),
        Anchor(
            id: "food-seeking",
            name: "Unconscious Food Seeking",
            description: "Primal sustenance drives, often sublimated into consumption rituals.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Regular Club")
            ]
        ),
        Anchor(
            id: "mobility",
            name: "Mobility",
            description: "Expansive freedom/speed vs. closed constraint/tunnel.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Time Collapse"),
                TentativeForm(context: "Subway", formName: "The Descent"),
                TentativeForm(context: "Subway", formName: "The Packed Car")
            ]
        ),
        Anchor(
            id: "power",
            name: "Power",
            description: "Seeking control over the environment or others; exercising agency.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Accidental Collaborator"),
                TentativeForm(context: "Subway", formName: "The Driver"),
                TentativeForm(context: "Subway", formName: "The Doors Closing")
            ]
        ),
        Anchor(
            id: "erotic-uncertainty",
            name: "Erotic Uncertainty",
            description: "The oscillation between pleasure and pain; the thrill of the unknown other.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Accidental Collaborator"),
                TentativeForm(context: "Coffee Shop", formName: "The Spill"),
                TentativeForm(context: "Subway", formName: "The Packed Car")
            ]
        ),
        Anchor(
            id: "material-play",
            name: "Material Play",
            description: "Engagement with physical substance and the texture of reality.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Spill"),
                TentativeForm(context: "Coffee Shop", formName: "The Construction"),
                TentativeForm(context: "Subway", formName: "The Stalled Train")
            ]
        ),
        Anchor(
            id: "nature-mirroring",
            name: "Nature Mirroring",
            description: "Seeing primal instincts or natural forces reflected in the built environment.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Time Collapse"),
                TentativeForm(context: "Subway", formName: "The Descent")
            ]
        ),
        Anchor(
            id: "serendipity-escapism",
            name: "Serendipity Escapism",
            description: "Following the happy accident away from reality; openness to the unscripted.",
            tentativeForms: [
                TentativeForm(context: "Coffee Shop", formName: "The Accidental Collaborator"),
                TentativeForm(context: "Coffee Shop", formName: "The Music Changes"),
                TentativeForm(context: "Subway", formName: "The Dream Commute")
            ]
        )
    ]
    
    /// Default anchor for new sessions
    static let defaultAnchor = allAnchors[1]  // Anxiety Navigation
}
