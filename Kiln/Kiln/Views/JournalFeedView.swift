import SwiftUI
import SwiftData

/// Journal feed showing all Phase 6 reflections chronologically
struct JournalFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \KilnSession.createdAt, order: .reverse) private var sessions: [KilnSession]
    
    @State private var searchText = ""
    @State private var filterAnchor: String?
    
    var completedSessions: [KilnSession] {
        sessions.filter { $0.isComplete }
    }
    
    var filteredSessions: [KilnSession] {
        var result = completedSessions
        
        if !searchText.isEmpty {
            result = result.filter { session in
                session.reflection(for: .observation).localizedCaseInsensitiveContains(searchText) ||
                session.roomName.localizedCaseInsensitiveContains(searchText) ||
                session.anchorName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let anchor = filterAnchor {
            result = result.filter { $0.anchorName == anchor }
        }
        
        return result
    }
    
    var uniqueAnchors: [String] {
        Array(Set(completedSessions.map { $0.anchorName })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if completedSessions.isEmpty {
                    ContentUnavailableView(
                        "No Journal Entries",
                        systemImage: "book",
                        description: Text("Complete a Kiln session to see your observations here.")
                    )
                } else {
                    List {
                        ForEach(Array(filteredSessions), id: \.self) { session in
                            JournalEntryRow(session: session)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search reflections...")
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("All Anchors") {
                            filterAnchor = nil
                        }
                        Divider()
                        ForEach(uniqueAnchors, id: \.self) { anchor in
                            Button(anchor) {
                                filterAnchor = anchor
                            }
                        }
                    } label: {
                        Label(
                            filterAnchor ?? "Filter",
                            systemImage: filterAnchor != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
                        )
                    }
                }
            }
        }
    }
}

struct JournalEntryRow: View {
    let session: KilnSession
    @State private var isExpanded = false
    
    var observationReflection: String {
        session.reflection(for: .observation)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.anchorName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                    
                    if !session.roomName.isEmpty {
                        Text(session.roomName)
                            .font(.headline)
                    }
                    
                    Text(session.createdAt, format: .dateTime.month(.abbreviated).day().year())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                if session.emptyHeatDuration > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text(formatDuration(session.emptyHeatDuration))
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }
            }
            
            // Observation reflection (Phase 6)
            if !observationReflection.isEmpty {
                Text(observationReflection)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(isExpanded ? nil : 3)
            }
            
            // Room spirit
            if !session.roomSpirit.isEmpty {
                Text(session.roomSpirit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
                    .lineLimit(isExpanded ? nil : 2)
            }
            
            // Expand/collapse for long entries
            if observationReflection.count > 150 || session.roomSpirit.count > 100 {
                Button(isExpanded ? "Show less" : "Show more") {
                    withAnimation { isExpanded.toggle() }
                }
                .font(.caption)
                .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        if minutes > 0 {
            return "\(minutes)m"
        }
        return "\(seconds)s"
    }
}

#Preview {
    JournalFeedView()
        .modelContainer(for: KilnSession.self, inMemory: true)
}
