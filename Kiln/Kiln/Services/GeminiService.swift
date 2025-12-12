import Foundation

/// Service for interacting with Google Gemini API
actor GeminiService {
    static let shared = GeminiService()
    private init() {}
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    enum GeminiError: Error, LocalizedError {
        case noAPIKey
        case invalidResponse
        case apiError(String)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .noAPIKey: return "No API key configured. Add your Gemini API key in Settings."
            case .invalidResponse: return "Invalid response from Gemini."
            case .apiError(let message): return message
            case .networkError(let error): return error.localizedDescription
            }
        }
    }
    
    // MARK: - Phase 2: Anchor Heating
    /// Generate thought-provoking questions to amplify the anchor
    func generateHeating(anchor: String, form: String) async throws -> [String] {
        let prompt = """
        You are helping someone explore their habitual experience through the Kiln process.
        
        The anchor (desire/habit) is: "\(anchor)"
        The specific form/situation is: "\(form)"
        
        Generate 3 thought-provoking questions or prompts that help "heat" this anchor - 
        meaning to intensify awareness of this desire, make it more vivid, and explore its edges.
        
        Keep each prompt to 1-2 sentences. Be evocative, not clinical.
        Return ONLY the 3 prompts, one per line, no numbering.
        """
        
        return try await generateList(prompt: prompt)
    }
    
    // MARK: - Phase 4: Form Settling
    /// Generate potential crystallized forms based on session reflections
    func generateForms(anchor: String, form: String, reflections: [String]) async throws -> [String] {
        let context = reflections.filter { !$0.isEmpty }.joined(separator: "\n---\n")
        
        let prompt = """
        You are helping someone complete the Kiln process of transforming habitual experience.
        
        Anchor: "\(anchor)"
        Starting form: "\(form)"
        
        Their reflections so far:
        \(context)
        
        Generate 3 potential "new forms" - these are crystallized, transformed versions of the original experience.
        Each should feel like a fresh perspective or reconfigured relationship to the anchor.
        
        Keep each to 1-2 sentences. Be poetic but grounded.
        Return ONLY the 3 forms, one per line, no numbering.
        """
        
        return try await generateList(prompt: prompt)
    }
    
    // MARK: - Phase 5: Room Emergence
    /// Generate a Room name and spirit based on the full session
    func generateRoom(anchor: String, form: String, reflections: [String], roomContext: String) async throws -> (name: String, spirit: String) {
        let context = reflections.filter { !$0.isEmpty }.joined(separator: "\n---\n")
        
        let prompt = """
        You are helping someone name a new "Room" that has emerged from their Kiln session.
        
        In the Kiln process, a Room is a newly discovered form of experience - a space of possibility.
        
        Anchor: "\(anchor)"
        Starting form: "\(form)"
        
        Session reflections:
        \(context)
        
        \(roomContext.isEmpty ? "" : "Additional context: \(roomContext)")
        
        Generate a Room name (2-4 words, evocative, like naming a place in a dream) 
        and a Room spirit (1-2 sentences describing the essence of this new space).
        
        Format your response EXACTLY as:
        NAME: [room name]
        SPIRIT: [room spirit]
        """
        
        let response = try await generate(prompt: prompt)
        
        // Parse response
        var name = ""
        var spirit = ""
        
        for line in response.components(separatedBy: "\n") {
            if line.uppercased().hasPrefix("NAME:") {
                name = line.replacingOccurrences(of: "NAME:", with: "", options: .caseInsensitive).trimmingCharacters(in: .whitespaces)
            } else if line.uppercased().hasPrefix("SPIRIT:") {
                spirit = line.replacingOccurrences(of: "SPIRIT:", with: "", options: .caseInsensitive).trimmingCharacters(in: .whitespaces)
            }
        }
        
        return (name, spirit)
    }
    
    // MARK: - Private Helpers
    
    private func generateList(prompt: String) async throws -> [String] {
        let response = try await generate(prompt: prompt)
        return response
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    private func generate(prompt: String) async throws -> String {
        guard let apiKey = KeychainHelper.shared.geminiAPIKey, !apiKey.isEmpty else {
            throw GeminiError.noAPIKey
        }
        
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 500
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GeminiError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw GeminiError.apiError(message)
                }
                throw GeminiError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let firstCandidate = candidates.first,
                  let content = firstCandidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let firstPart = parts.first,
                  let text = firstPart["text"] as? String else {
                throw GeminiError.invalidResponse
            }
            
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as GeminiError {
            throw error
        } catch {
            throw GeminiError.networkError(error)
        }
    }
}
