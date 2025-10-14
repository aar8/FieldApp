import SwiftUI

struct ContentView: View {
    let viewFactory: ViewFactory

    var body: some View {
        viewFactory.makeJobListView()
    }
}

#Preview {
    // For the preview, we create a factory with a mock service.
    let factory = ViewFactory(databaseService: MockDatabaseService())
    ContentView(viewFactory: factory)
}
