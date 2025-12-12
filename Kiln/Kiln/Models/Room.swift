import Foundation
import SwiftData

/// A Room is a new form that emerges from the Kiln process
@Model
final class Room {
    var name: String
    var spirit: String
    var createdAt: Date
    var anchorName: String
    var startingForm: String
    
    /// The session that created this room
    @Relationship var originSession: KilnSession?
    
    /// Adjacent rooms (bidirectional many-to-many)
    @Relationship var adjacentRooms: [Room]
    
    init(
        name: String,
        spirit: String,
        anchorName: String,
        startingForm: String,
        originSession: KilnSession? = nil
    ) {
        self.name = name
        self.spirit = spirit
        self.createdAt = Date()
        self.anchorName = anchorName
        self.startingForm = startingForm
        self.originSession = originSession
        self.adjacentRooms = []
    }
    
    /// Check if this room is adjacent to another
    func isAdjacent(to room: Room) -> Bool {
        adjacentRooms.contains(where: { $0.id == room.id })
    }
    
    /// Add adjacency (bidirectional)
    func addAdjacency(to room: Room) {
        if !isAdjacent(to: room) {
            adjacentRooms.append(room)
            room.adjacentRooms.append(self)
        }
    }
    
    /// Remove adjacency (bidirectional)
    func removeAdjacency(from room: Room) {
        adjacentRooms.removeAll { $0.id == room.id }
        room.adjacentRooms.removeAll { $0.id == self.id }
    }
}
