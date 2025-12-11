import SwiftUI

struct SummaryView: View {
    let session: KilnSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Complete")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(session.anchor) → \(session.startingForm)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Reflections by phase
                    ForEach(Array(KilnPhase.allCases), id: \.self) { phase in
                        PhaseSummaryRow(phase: phase, reflection: session.reflections[phase])
                    }
                    
                    // New room emerged
                    if !session.roomName.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Room Emerged")
                                .font(.headline)
                            Text(session.roomName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            if !session.roomSpirit.isEmpty {
                                Text(session.roomSpirit)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct PhaseSummaryRow: View {
    let phase: KilnPhase
    let reflection: String?
    
    var body: some View {
        if let reflection = reflection, !reflection.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(phase.title)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                
                Text(reflection)
                    .font(.body)
            }
        }
    }
}

#Preview {
    var session = KilnSession.createDefault()
    session.reflections[.enumeratedBed] = "The need to feel connected drives constant WiFi checking."
    session.reflections[.anchorHeating] = "Turning off WiFi entirely—removing the possibility of resolution."
    session.reflections[.emptyHeat] = "The urge to leave. The feeling of being unproductive."
    session.reflections[.formTying] = "The anxiety binds to the soundscape of the shop."
    session.reflections[.formSettling] = "The Analog Commons—a room of voyeuristic calm."
    session.reflections[.observation] = "The anxiety of disconnection was actually an anxiety of silence."
    return SummaryView(session: session)
}
