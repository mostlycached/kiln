import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Bindable var session: KilnSession
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingSummary = false
    @State private var showingTimer = false
    
    // Collect all reflections for AI context
    private var allReflections: [String] {
        KilnPhase.allCases.map { session.reflection(for: $0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anchor: \(session.anchorName)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(session.startingForm)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 8)
                
                // 6 Phases
                ForEach(Array(KilnPhase.allCases), id: \.self) { phase in
                    PhaseCard(
                        phase: phase,
                        reflection: Binding(
                            get: { session.reflection(for: phase) },
                            set: { session.setReflection($0, for: phase) }
                        ),
                        onTimerTap: phase == .emptyHeat ? { showingTimer = true } : nil,
                        timerDuration: phase == .emptyHeat ? session.emptyHeatDuration : 0,
                        anchorName: session.anchorName,
                        formName: session.startingForm,
                        allReflections: allReflections
                    )
                }
                
                // Room naming section
                RoomNamingCard(
                    roomName: $session.roomName,
                    roomSpirit: $session.roomSpirit,
                    anchorName: session.anchorName,
                    formName: session.startingForm,
                    allReflections: allReflections
                )
                
                // Complete Button
                Button(action: completeSession) {
                    Text(session.isComplete ? "View Summary" : "Complete Session")
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
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSummary) {
            SummaryView(session: session)
        }
        .sheet(isPresented: $showingTimer) {
            EmptyHeatTimerView(
                isPresented: $showingTimer,
                elapsedDuration: $session.emptyHeatDuration
            )
        }
    }
    
    private func completeSession() {
        session.isComplete = true
        
        // Create a Room if one was named
        if !session.roomName.isEmpty {
            let room = Room(
                name: session.roomName,
                spirit: session.roomSpirit,
                anchorName: session.anchorName,
                startingForm: session.startingForm,
                originSession: session
            )
            modelContext.insert(room)
        }
        
        showingSummary = true
    }
}

struct RoomNamingCard: View {
    @Binding var roomName: String
    @Binding var roomSpirit: String
    
    var anchorName: String = ""
    var formName: String = ""
    var allReflections: [String] = []
    
    @State private var isLoadingAI = false
    @State private var aiError: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("New Room")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if KeychainHelper.shared.hasAPIKey {
                    Button(action: generateRoom) {
                        HStack(spacing: 4) {
                            if isLoadingAI {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text("Dream")
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.15))
                        .foregroundStyle(.purple)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoadingAI)
                }
            }
            
            Text("If a new form has crystallized, give it a name and capture its spirit.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let error = aiError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            TextField("Room name...", text: $roomName)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            TextField("Spirit of the room...", text: $roomSpirit, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .lineLimit(2...4)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func generateRoom() {
        guard !isLoadingAI else { return }
        isLoadingAI = true
        aiError = nil
        
        Task {
            do {
                let result = try await GeminiService.shared.generateRoom(
                    anchor: anchorName,
                    form: formName,
                    reflections: allReflections,
                    roomContext: ""
                )
                
                await MainActor.run {
                    roomName = result.name
                    roomSpirit = result.spirit
                    isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    aiError = error.localizedDescription
                    isLoadingAI = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: KilnSession())
    }
    .modelContainer(for: [KilnSession.self, Room.self], inMemory: true)
}
