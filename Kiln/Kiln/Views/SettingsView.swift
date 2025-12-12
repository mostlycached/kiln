import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var showingKey = false
    @State private var saveMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showingKey {
                            TextField("API Key", text: $apiKey)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("API Key", text: $apiKey)
                        }
                        
                        Button(action: { showingKey.toggle() }) {
                            Image(systemName: showingKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Gemini API Key")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your API key is stored securely in the device Keychain.")
                        Link("Get a Gemini API Key", destination: URL(string: "https://aistudio.google.com/apikey")!)
                    }
                }
                
                if let message = saveMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(message.contains("Error") ? .red : .green)
                    }
                }
                
                Section {
                    Button("Save API Key") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty)
                    
                    if KeychainHelper.shared.hasAPIKey {
                        Button("Remove API Key", role: .destructive) {
                            removeAPIKey()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                apiKey = KeychainHelper.shared.geminiAPIKey ?? ""
            }
        }
    }
    
    private func saveAPIKey() {
        KeychainHelper.shared.geminiAPIKey = apiKey
        saveMessage = "API Key saved successfully!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            saveMessage = nil
        }
    }
    
    private func removeAPIKey() {
        KeychainHelper.shared.geminiAPIKey = nil
        apiKey = ""
        saveMessage = "API Key removed."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            saveMessage = nil
        }
    }
}

#Preview {
    SettingsView()
}
