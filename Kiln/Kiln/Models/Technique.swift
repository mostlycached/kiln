import Foundation

/// A technique used in a specific phase of the Kiln process
struct Technique: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let phase: KilnPhase
}

/// All techniques organized by phase from THESIS.md
extension Technique {
    static let allTechniques: [KilnPhase: [Technique]] = [
        .enumeratedBed: [
            Technique(
                id: "symptom-tracing",
                name: "Symptom Tracing",
                description: "Notice where energy/time goes and ask: what desire does this serve?",
                phase: .enumeratedBed
            ),
            Technique(
                id: "inventory-lists",
                name: "Inventory Lists",
                description: "Catalog habits, spaces, and recurring loops.",
                phase: .enumeratedBed
            ),
            Technique(
                id: "structural-mapping",
                name: "Structural Mapping",
                description: "Draw the current 'house' of habits to see the load-bearing walls.",
                phase: .enumeratedBed
            )
        ],
        .anchorHeating: [
            Technique(
                id: "defamiliarization",
                name: "Defamiliarization",
                description: "Describe the ordinary as if seen for the first time.",
                phase: .anchorHeating
            ),
            Technique(
                id: "constraint-removal",
                name: "Constraint Removal",
                description: "Physically block the habitual path to force a new response.",
                phase: .anchorHeating
            ),
            Technique(
                id: "over-saturation",
                name: "Over-saturation",
                description: "Repeat the habit until it loses meaning (semantic satiation).",
                phase: .anchorHeating
            ),
            Technique(
                id: "scale-shift",
                name: "Scale Shift",
                description: "View the personal habit through a geological or microscopic lens.",
                phase: .anchorHeating
            )
        ],
        .emptyHeat: [
            Technique(
                id: "the-pause",
                name: "The Pause",
                description: "Deliberate stillness when the impulse to act arises.",
                phase: .emptyHeat
            ),
            Technique(
                id: "non-resolution",
                name: "Non-Resolution",
                description: "Refuse to 'fix' the problem immediately.",
                phase: .emptyHeat
            ),
            Technique(
                id: "silent-witnessing",
                name: "Silent Witnessing",
                description: "Observe the anxiety of the gap without intervening.",
                phase: .emptyHeat
            ),
            Technique(
                id: "journaling-void",
                name: "Journaling the Void",
                description: "Document the specific quality of the formlessness.",
                phase: .emptyHeat
            )
        ],
        .formTying: [
            Technique(
                id: "randomized-injection",
                name: "Randomized Injection",
                description: "Introduce a random element (a card, a word, a person) into the vacuum.",
                phase: .formTying
            ),
            Technique(
                id: "role-reversal",
                name: "Role Reversal",
                description: "Invert the usual power dynamic or vector.",
                phase: .formTying
            ),
            Technique(
                id: "cross-pollination",
                name: "Cross-Pollination",
                description: "Import a rule from a different domain.",
                phase: .formTying
            ),
            Technique(
                id: "material-play",
                name: "Material Play",
                description: "Physically handle new materials (clay, sound, light) to see what sticks.",
                phase: .formTying
            )
        ],
        .formSettling: [
            Technique(
                id: "ritualization",
                name: "Ritualization",
                description: "Establish a precise sequence of actions for the new form.",
                phase: .formSettling
            ),
            Technique(
                id: "naming",
                name: "Naming",
                description: "Give the new room a proper name.",
                phase: .formSettling
            ),
            Technique(
                id: "deliberate-practice",
                name: "Deliberate Practice",
                description: "Repeat the new loop 10x with intent.",
                phase: .formSettling
            ),
            Technique(
                id: "constraint-setting",
                name: "Constraint Setting",
                description: "Define the 'walls' of the new room (what is allowed/not allowed).",
                phase: .formSettling
            )
        ],
        .observation: [
            Technique(
                id: "thick-description",
                name: "Thick Description",
                description: "Ethnographic recording of the experience.",
                phase: .observation
            ),
            Technique(
                id: "spirit-capture",
                name: "Spirit Capture",
                description: "Identify the 'fire' or mood of the room.",
                phase: .observation
            ),
            Technique(
                id: "transmission",
                name: "Transmission",
                description: "Write the 'Instruction Manual' for others to enter.",
                phase: .observation
            ),
            Technique(
                id: "evaluation",
                name: "Evaluation",
                description: "Does this form satisfy the anchor better? Is it more permeable?",
                phase: .observation
            )
        ]
    ]
    
    static func techniques(for phase: KilnPhase) -> [Technique] {
        allTechniques[phase] ?? []
    }
}
