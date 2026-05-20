import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RafterView()
                .tabItem { Label("Rafter", systemImage: "triangle") }
            StairView()
                .tabItem { Label("Stairs", systemImage: "stairs") }
            ConcreteView()
                .tabItem { Label("Concrete", systemImage: "cube") }
            MaterialView()
                .tabItem { Label("Materials", systemImage: "square.3.layers.3d") }
            QuoteView()
                .tabItem { Label("Quote", systemImage: "doc.text") }
            SnowView()
                .tabItem { Label("Snow Load", systemImage: "snowflake") }
            BeamView()
                .tabItem { Label("Beam Span", systemImage: "ruler") }
            DrainageView()
                .tabItem { Label("Drainage", systemImage: "drop") }
            WallFramingView()
                .tabItem { Label("Wall Framing", systemImage: "rectangle.split.3x1") }
            MoreView()
                .tabItem { Label("More", systemImage: "ellipsis") }
        }
        .accentColor(Color(hex: "1A1A1A"))
    }
}
