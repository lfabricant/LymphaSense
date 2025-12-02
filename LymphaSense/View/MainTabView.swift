import SwiftUI

struct MainTabView: View {
    // Access the shared manager from the environment
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            DataView()
                .tabItem {
                    Label("Data", systemImage: "gauge.chart.lefthalf.righthalf")
                }
            
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "waveform.path.ecg.rectangle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

// ----------------------------------------------------
// Preview
// ----------------------------------------------------

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// NOTE: You must have stubs or definitions for HomeView, DataView, TrendsView,
// ProfileView, and BluetoothView (which accepts the @ObservedObject) defined elsewhere.
