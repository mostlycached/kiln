import SwiftUI
import SwiftData

struct CustomAnchorListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomAnchor.createdAt, order: .reverse) private var customAnchors: [CustomAnchor]
    @State private var showingNewAnchor = false
    
    var body: some View {
        Group {
            if customAnchors.isEmpty {
                ContentUnavailableView(
                    "No Custom Anchors",
                    systemImage: "plus.circle",
                    description: Text("Create your own anchors to explore unique desires.")
                )
            } else {
                List {
                    ForEach(Array(customAnchors), id: \.self) { anchor in
                        NavigationLink(destination: EditCustomAnchorView(anchor: anchor)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(anchor.name)
                                        .font(.headline)
                                    Spacer()
                                    Text("Custom")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                Text(anchor.anchorDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                Text("\(anchor.tentativeForms.count) forms")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteAnchors)
                }
            }
        }
        .navigationTitle("Custom Anchors")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewAnchor = true }) {
                    Label("New Anchor", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewAnchor) {
            NewCustomAnchorView()
        }
    }
    
    private func deleteAnchors(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(customAnchors[index])
        }
    }
}

struct NewCustomAnchorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var forms: [TentativeFormData] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Anchor Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Tentative Forms") {
                    ForEach(Array(forms.enumerated()), id: \.element.id) { index, _ in
                        HStack {
                            TextField("Context", text: $forms[index].context)
                                .frame(width: 100)
                            TextField("Form Name", text: $forms[index].formName)
                        }
                    }
                    .onDelete { indexSet in
                        forms.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: addForm) {
                        Label("Add Form", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Anchor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAnchor() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addForm() {
        forms.append(TentativeFormData())
    }
    
    private func saveAnchor() {
        let anchor = CustomAnchor(
            name: name,
            description: description,
            tentativeForms: forms.filter { !$0.formName.isEmpty }
        )
        modelContext.insert(anchor)
        dismiss()
    }
}

struct EditCustomAnchorView: View {
    @Bindable var anchor: CustomAnchor
    @State private var forms: [TentativeFormData] = []
    
    var body: some View {
        Form {
            Section("Anchor Details") {
                TextField("Name", text: $anchor.name)
                TextField("Description", text: $anchor.anchorDescription, axis: .vertical)
                    .lineLimit(2...4)
            }
            
            Section("Tentative Forms") {
                ForEach(Array(forms.enumerated()), id: \.element.id) { index, _ in
                    HStack {
                        TextField("Context", text: $forms[index].context)
                            .frame(width: 100)
                        TextField("Form Name", text: $forms[index].formName)
                    }
                }
                .onDelete { indexSet in
                    forms.remove(atOffsets: indexSet)
                    anchor.tentativeForms = forms.filter { !$0.formName.isEmpty }
                }
                
                Button(action: addForm) {
                    Label("Add Form", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Edit Anchor")
        .onAppear {
            forms = anchor.tentativeForms
        }
        .onChange(of: forms) { _, newValue in
            anchor.tentativeForms = newValue.filter { !$0.formName.isEmpty }
        }
    }
    
    private func addForm() {
        forms.append(TentativeFormData())
    }
}

#Preview {
    NavigationStack {
        CustomAnchorListView()
    }
    .modelContainer(for: CustomAnchor.self, inMemory: true)
}
