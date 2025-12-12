import SwiftUI

struct AnchorPickerView: View {
    @Binding var selectedAnchor: Anchor
    @Binding var selectedForm: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(Anchor.allAnchors), id: \.id) { anchor in
                    AnchorSection(
                        anchor: anchor,
                        isSelected: selectedAnchor.id == anchor.id,
                        selectedForm: selectedForm,
                        onSelectAnchor: { selectAnchor(anchor) },
                        onSelectForm: { selectForm($0) }
                    )
                }
            }
            .navigationTitle("Select Anchor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func selectAnchor(_ anchor: Anchor) {
        selectedAnchor = anchor
        if let firstForm = anchor.tentativeForms.first {
            selectedForm = firstForm.formName
        }
    }
    
    private func selectForm(_ formName: String) {
        selectedForm = formName
    }
}

struct AnchorSection: View {
    let anchor: Anchor
    let isSelected: Bool
    let selectedForm: String
    let onSelectAnchor: () -> Void
    let onSelectForm: (String) -> Void
    
    var body: some View {
        Section {
            AnchorRow(anchor: anchor, isSelected: isSelected, onTap: onSelectAnchor)
            
            if isSelected {
                ForEach(Array(anchor.tentativeForms), id: \.id) { form in
                    FormRow(
                        form: form,
                        isSelected: selectedForm == form.formName,
                        onTap: { onSelectForm(form.formName) }
                    )
                }
            }
        }
    }
}

struct AnchorRow: View {
    let anchor: Anchor
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(anchor.name)
                        .font(.headline)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text(anchor.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct FormRow: View {
    let form: Anchor.TentativeForm
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(form.formName)
                        .font(.subheadline)
                    Text(form.context)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AnchorPickerView(
        selectedAnchor: .constant(Anchor.defaultAnchor),
        selectedForm: .constant("The WiFi Fails")
    )
}
