import SwiftUI

struct ContentView: View {
    let viewFactory: ViewFactory

    var body: some View {
        viewFactory.makeJobListView()
    }
}

