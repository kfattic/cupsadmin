import SwiftUI

@main
struct CUPSAdminApp: App {
    var body: some Scene {
        // Single-window utility; SwiftUI saves and restores the window frame.
        Window("CUPS Admin", id: "main") {
            ContentView()
        }
        .defaultSize(width: 980, height: 640)
    }
}
