import SwiftUI

/// Shared component for displaying a phase card with reflection input, techniques, and AI suggestions
struct PhaseCard: View {
    let phase: KilnPhase
    @Binding var reflection: String
    var onTimerTap: (() -> Void)? = nil
    var timerDuration: TimeInterval = 0
    
    // Context for AI generation
    var anchorName: String = ""
    var formName: String = ""
    var allReflections: [String] = []
    
    @State private var showingTechniques = false
    @State private var aiSuggestions: [String] = []
    @State private var isLoadingAI = false
    @State private var aiError: String?
    
    private var techniques: [Technique] {
        Technique.techniques(for: phase)
    }
    
    private var showsAI: Bool {
        phase == .anchorHeating || phase == .formSettling
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(phase.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // AI button for supported phases
                if showsAI && KeychainHelper.shared.hasAPIKey {
                    AIButton(isLoading: isLoadingAI, onTap: generateSuggestions)
                }
                
                // Timer button for Empty Heat phase
                if phase == .emptyHeat, let onTimerTap = onTimerTap {
                    TimerBadge(duration: timerDuration, onTap: onTimerTap)
                }
            }
            
            Text(phase.prompt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // AI Suggestions
            if !aiSuggestions.isEmpty {
                AISuggestionsView(
                    suggestions: aiSuggestions,
                    onSelect: { suggestion in
                        if reflection.isEmpty {
                            reflection = suggestion
                        } else {
                            reflection += "\n\n" + suggestion
                        }
                        aiSuggestions = []
                    },
                    onDismiss: { aiSuggestions = [] }
                )
            }
            
            if let error = aiError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            // Technique chips
            TechniqueSection(techniques: techniques, isExpanded: $showingTechniques)
            
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
    
    private func generateSuggestions() {
        guard !isLoadingAI else { return }
        isLoadingAI = true
        aiError = nil
        
        Task {
            do {
                let suggestions: [String]
                
                switch phase {
                case .anchorHeating:
                    suggestions = try await GeminiService.shared.generateHeating(
                        anchor: anchorName,
                        form: formName
                    )
                case .formSettling:
                    suggestions = try await GeminiService.shared.generateForms(
                        anchor: anchorName,
                        form: formName,
                        reflections: allReflections
                    )
                default:
                    suggestions = []
                }
                
                await MainActor.run {
                    aiSuggestions = suggestions
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

struct AIButton: View {
    let isLoading: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "sparkles")
                }
                Text("AI")
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.15))
            .foregroundStyle(.purple)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct AISuggestionsView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("AI Suggestions")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.purple)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                Button(action: { onSelect(suggestion) }) {
                    Text(suggestion)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.purple.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct TimerBadge: View {
    let duration: TimeInterval
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: duration > 0 ? "checkmark.circle.fill" : "timer")
                    .foregroundStyle(duration > 0 ? .green : Color.accentColor)
                if duration > 0 {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Timer")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(duration > 0 ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

struct TechniqueSection: View {
    let techniques: [Technique]
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("Techniques")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                FlowLayout(spacing: 8) {
                    ForEach(Array(techniques), id: \.id) { technique in
                        TechniqueChip(technique: technique)
                    }
                }
            } else {
                Text(techniques.map { $0.name }.joined(separator: " • "))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
    }
}

struct TechniqueChip: View {
    let technique: Technique
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail.toggle() }) {
            Text(technique.name)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .foregroundStyle(Color.accentColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingDetail) {
            VStack(alignment: .leading, spacing: 8) {
                Text(technique.name)
                    .font(.headline)
                Text(technique.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

/// Simple flow layout for technique chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), frames)
    }
}

#Preview {
    PhaseCard(
        phase: .anchorHeating,
        reflection: .constant("Test reflection"),
        anchorName: "Anxiety Navigation",
        formName: "The WiFi Fails"
    )
    .padding()
}
