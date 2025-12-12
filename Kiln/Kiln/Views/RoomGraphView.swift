import SwiftUI
import SwiftData

struct RoomGraphView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]
    @State private var selectedRoom: Room?
    @State private var showingLinkSheet = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color(.systemBackground)
                    
                    if rooms.isEmpty {
                        ContentUnavailableView(
                            "No Rooms",
                            systemImage: "square.grid.3x3.topleft.filled",
                            description: Text("Complete Kiln sessions with new rooms to see the graph.")
                        )
                    } else {
                        // Simple grid layout for rooms
                        RoomNodesView(
                            rooms: rooms,
                            selectedRoom: $selectedRoom,
                            geometry: geometry
                        )
                    }
                }
            }
            .navigationTitle("Room Graph")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedRoom) { room in
                RoomDetailSheet(room: room, allRooms: rooms)
            }
        }
    }
}

struct RoomNodesView: View {
    let rooms: [Room]
    @Binding var selectedRoom: Room?
    let geometry: GeometryProxy
    
    var body: some View {
        let columns = max(2, Int(sqrt(Double(rooms.count))))
        let nodeSize: CGFloat = 80
        let spacing: CGFloat = 40
        
        ZStack {
            // Draw edges first
            ForEach(Array(rooms), id: \.self) { room in
                ForEach(Array(room.adjacentRooms), id: \.self) { adjacent in
                    if let fromIndex = rooms.firstIndex(where: { $0.id == room.id }),
                       let toIndex = rooms.firstIndex(where: { $0.id == adjacent.id }),
                       fromIndex < toIndex {  // Only draw once per pair
                        let fromPos = nodePosition(index: fromIndex, columns: columns, nodeSize: nodeSize, spacing: spacing, geometry: geometry)
                        let toPos = nodePosition(index: toIndex, columns: columns, nodeSize: nodeSize, spacing: spacing, geometry: geometry)
                        
                        Path { path in
                            path.move(to: fromPos)
                            path.addLine(to: toPos)
                        }
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 2)
                    }
                }
            }
            
            // Draw nodes
            ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
                let position = nodePosition(index: index, columns: columns, nodeSize: nodeSize, spacing: spacing, geometry: geometry)
                
                RoomNode(room: room, isSelected: selectedRoom?.id == room.id)
                    .frame(width: nodeSize, height: nodeSize)
                    .position(position)
                    .onTapGesture {
                        selectedRoom = room
                    }
            }
        }
    }
    
    private func nodePosition(index: Int, columns: Int, nodeSize: CGFloat, spacing: CGFloat, geometry: GeometryProxy) -> CGPoint {
        let row = index / columns
        let col = index % columns
        let totalWidth = CGFloat(columns) * (nodeSize + spacing)
        let startX = (geometry.size.width - totalWidth) / 2 + nodeSize / 2 + spacing / 2
        let startY: CGFloat = 100
        
        return CGPoint(
            x: startX + CGFloat(col) * (nodeSize + spacing),
            y: startY + CGFloat(row) * (nodeSize + spacing)
        )
    }
}

struct RoomNode: View {
    let room: Room
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color.accentColor.opacity(isSelected ? 1.0 : 0.7))
                .overlay(
                    Text(String(room.name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                )
            
            Text(room.name)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
    }
}

struct RoomDetailSheet: View {
    @Bindable var room: Room
    let allRooms: [Room]
    @Environment(\.dismiss) private var dismiss
    @State private var showingLinkPicker = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Room Info") {
                    LabeledContent("Name", value: room.name)
                    if !room.spirit.isEmpty {
                        LabeledContent("Spirit", value: room.spirit)
                    }
                    LabeledContent("Anchor", value: room.anchorName)
                    LabeledContent("Form", value: room.startingForm)
                    LabeledContent("Created", value: room.createdAt, format: .dateTime.day().month().year())
                }
                
                Section("Adjacent Rooms (\(room.adjacentRooms.count))") {
                    if room.adjacentRooms.isEmpty {
                        Text("No adjacent rooms yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(room.adjacentRooms), id: \.self) { adjacent in
                            HStack {
                                Text(adjacent.name)
                                Spacer()
                                Button(action: { room.removeAdjacency(from: adjacent) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Button(action: { showingLinkPicker = true }) {
                        Label("Link Room", systemImage: "plus")
                    }
                }
            }
            .navigationTitle(room.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingLinkPicker) {
                RoomLinkPicker(room: room, allRooms: allRooms)
            }
        }
    }
}

struct RoomLinkPicker: View {
    let room: Room
    let allRooms: [Room]
    @Environment(\.dismiss) private var dismiss
    
    var availableRooms: [Room] {
        allRooms.filter { other in
            other.id != room.id && !room.isAdjacent(to: other)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if availableRooms.isEmpty {
                    Text("No rooms available to link")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(availableRooms), id: \.self) { other in
                        Button(action: {
                            room.addAdjacency(to: other)
                            dismiss()
                        }) {
                            VStack(alignment: .leading) {
                                Text(other.name)
                                    .font(.headline)
                                Text(other.anchorName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Link to Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    RoomGraphView()
        .modelContainer(for: [Room.self, KilnSession.self], inMemory: true)
}
