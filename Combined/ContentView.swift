//
//  ContentView.swift
//  AMAL
//
//  Created by Lindsay on 10/27/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        // tabs at bottom
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

