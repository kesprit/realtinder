import SwiftUI

@main
struct RealtinderApp: App {
    init() {
        DIConfig.configure()
    }

    var body: some Scene {
        WindowGroup {
            DiscoverView()
        }
    }
}
