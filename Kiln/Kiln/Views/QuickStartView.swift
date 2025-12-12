import SwiftUI
import SwiftData

/// Quick start shortcuts for common session starts
struct QuickStartView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \KilnSession.createdAt, order: .reverse) private var recentSessions: [KilnSession]
    @Query private var customAnchors: [CustomAnchor]
    
    let onSessionCreated: (KilnSession) -> Void
    
    var recentAnchors: [(String, String)] {
        // Get the 3 most recently used anchor/form combinations
        var seen = Set<String>()
        var result: [(String, String)] = []
        for session in recentSessions {
            let key = "\(session.anchorName)::\(session.startingForm)"
            if !seen.contains(key) {
                seen.insert(key)
                result.append((session.anchorName, session.startingForm))
            }
            if result.count >= 3 { break }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Recent shortcuts
                    if !recentAnchors.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent")
                                .font(.headline)
                            
                            ForEach(Array(recentAnchors.enumerated()), id: \.offset) { _, pair in
                                QuickStartButton(
                                    anchor: pair.0,
                                    form: pair.1,
                                    action: { quickStart(anchor: pair.0, form: pair.1) }
                                )
                            }
                        }
                    }
                    
                    // Favorite anchors section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Start Anchors")
                            .font(.headline)
                        
                        // Top 3 system anchors
                        ForEach(Array(Anchor.allAnchors.prefix(3)), id: \.id) { anchor in
                            QuickStartButton(
                                anchor: anchor.name,
                                form: anchor.tentativeForms.first?.formName ?? "",
                                action: {
                                    quickStart(
                                        anchor: anchor.name,
                                        form: anchor.tentativeForms.first?.formName ?? anchor.name
                                    )
                                }
                            )
                        }
                    }
                    
                    // Custom anchors
                    if !customAnchors.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Custom Anchors")
                                .font(.headline)
                            
                            ForEach(Array(customAnchors.prefix(3)), id: \.self) { anchor in
                                QuickStartButton(
                                    anchor: anchor.name,
                                    form: anchor.tentativeForms.first?.formName ?? "",
                                    isCustom: true,
                                    action: {
                                        quickStart(
                                            anchor: anchor.name,
                                            form: anchor.tentativeForms.first?.formName ?? anchor.name
                                        )
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Quick Start")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func quickStart(anchor: String, form: String) {
        let session = KilnSession(anchorName: anchor, startingForm: form)
        modelContext.insert(session)
        onSessionCreated(session)
        dismiss()
    }
}

struct QuickStartButton: View {
    let anchor: String
    let form: String
    var isCustom: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(anchor)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if !form.isEmpty {
                        Text(form)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if isCustom {
                    Text("Custom")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Image(systemName: "play.fill")
                    .foregroundStyle(Color.accentColor)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickStartView { _ in }
        .modelContainer(for: [KilnSession.self, CustomAnchor.self], inMemory: true)
}
