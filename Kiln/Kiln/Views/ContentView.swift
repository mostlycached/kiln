import SwiftUI

struct ContentView: View {
    @State private var session = KilnSession.createDefault()
    @State private var showingSummary = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anchor: \(session.anchor)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(session.startingForm)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 8)
                    
                    // 6 Phases
                    ForEach(Array(KilnPhase.allCases), id: \.self) { phase in
                        PhaseCard(phase: phase, reflection: binding(for: phase))
                    }
                    
                    // Complete Button
                    Button(action: { showingSummary = true }) {
                        Text("Complete Session")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
            .navigationTitle("Kiln")
            .sheet(isPresented: $showingSummary) {
                SummaryView(session: session)
            }
        }
    }
    
    private func binding(for phase: KilnPhase) -> Binding<String> {
        Binding(
            get: { session.reflections[phase] ?? "" },
            set: { session.reflections[phase] = $0 }
        )
    }
}

struct PhaseCard: View {
    let phase: KilnPhase
    @Binding var reflection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(phase.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(phase.prompt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("Your reflection...", text: $reflection, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .lineLimit(3...6)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    ContentView()
}
