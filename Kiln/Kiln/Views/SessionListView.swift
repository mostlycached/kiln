import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \KilnSession.createdAt, order: .reverse) private var sessions: [KilnSession]
    @State private var showingNewSession = false
    @State private var showingQuickStart = false
    @State private var selectedAnchor = Anchor.defaultAnchor
    @State private var selectedForm = "The WiFi Fails"
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions",
                        systemImage: "flame",
                        description: Text("Start your first Kiln session to begin transforming experiences.")
                    )
                } else {
                    List {
                        ForEach(sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionRow(session: session)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("Kiln")
            .navigationDestination(for: KilnSession.self) { session in
                SessionDetailView(session: session)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingNewSession = true }) {
                            Label("New Session", systemImage: "plus")
                        }
                        Button(action: { showingQuickStart = true }) {
                            Label("Quick Start", systemImage: "bolt.fill")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Menu {
                        NavigationLink(destination: CustomAnchorListView()) {
                            Label("Custom Anchors", systemImage: "plus.circle")
                        }
                        NavigationLink(destination: SettingsView()) {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingNewSession) {
                NewSessionView(
                    selectedAnchor: $selectedAnchor,
                    selectedForm: $selectedForm,
                    onStart: createSession
                )
            }
            .sheet(isPresented: $showingQuickStart) {
                QuickStartView { session in
                    navigationPath.append(session)
                }
            }
        }
    }
    
    private func createSession() {
        let session = KilnSession(
            anchorName: selectedAnchor.name,
            startingForm: selectedForm
        )
        modelContext.insert(session)
        showingNewSession = false
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

struct NewSessionView: View {
    @Binding var selectedAnchor: Anchor
    @Binding var selectedForm: String
    let onStart: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Selected anchor display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anchor")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(selectedAnchor.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(selectedAnchor.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Selected form
                VStack(alignment: .leading, spacing: 8) {
                    Text("Starting Form")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(selectedForm)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                // Anchor picker
                NavigationLink(destination: AnchorPickerView(
                    selectedAnchor: $selectedAnchor,
                    selectedForm: $selectedForm
                )) {
                    Text("Change Anchor")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Start button
                Button(action: onStart) {
                    Text("Start Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct SessionRow: View {
    let session: KilnSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.anchorName)
                    .font(.headline)
                Spacer()
                if session.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            Text(session.startingForm)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(session.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SessionListView()
        .modelContainer(for: KilnSession.self, inMemory: true)
}
