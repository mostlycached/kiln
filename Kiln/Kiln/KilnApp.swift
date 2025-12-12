import SwiftUI
import SwiftData

@main
struct KilnApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [KilnSession.self, Room.self, CustomAnchor.self])
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            SessionListView()
                .tabItem {
                    Label("Sessions", systemImage: "flame")
                }
            
            JournalFeedView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            
            NavigationStack {
                RoomLibraryView()
            }
            .tabItem {
                Label("Rooms", systemImage: "house")
            }
            
            RoomGraphView()
                .tabItem {
                    Label("Graph", systemImage: "point.3.connected.trianglepath.dotted")
                }
        }
    }
}
