import SwiftUI
import SwiftData

struct RoomLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Room.createdAt, order: .reverse) private var rooms: [Room]
    
    var body: some View {
        Group {
            if rooms.isEmpty {
                ContentUnavailableView(
                    "No Rooms",
                    systemImage: "house",
                    description: Text("Complete a Kiln session with a new room to see it here.")
                )
            } else {
                List {
                    ForEach(Array(rooms), id: \.self) { room in
                        RoomRow(room: room)
                    }
                    .onDelete(perform: deleteRooms)
                }
            }
        }
        .navigationTitle("Rooms")
    }
    
    private func deleteRooms(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(rooms[index])
        }
    }
}

struct RoomRow: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(room.name)
                .font(.headline)
            
            if !room.spirit.isEmpty {
                Text(room.spirit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text("From: \(room.anchorName)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(room.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RoomLibraryView()
    }
    .modelContainer(for: [Room.self, KilnSession.self], inMemory: true)
}
