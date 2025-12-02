//  HomeView.swift

//  LymphaSense

//

//  Created by Lindsay on 11/28/25.

//

/*

import SwiftUI

import CoreBluetooth



struct HomeView: View {

    

    // Access the shared BluetoothManager instance

    @EnvironmentObject var bluetoothManager: BluetoothManager

    

    var body: some View {

        VStack {

            Text("Dashboard")

                .font(.largeTitle)

                .padding()

            

            // Display connection status

            Text(bluetoothManager.isConnected ? "Status: Connected ✅" : "Status: Disconnected ❌")

                .foregroundColor(bluetoothManager.isConnected ? .green : .red)

                .padding(.bottom, 20)

            

            Divider()

        
            // 🎯 Display the data history in a scrolling list

            List {

                // Use .reversed() to show the newest data at the top of the list

                ForEach(bluetoothManager.receivedDataHistory.reversed(), id: \.self) { dataString in

                    Text(dataString)

                        .font(.body)

                }

            }

            .listStyle(.plain)

            

            Spacer()

        }

        .padding()

        .navigationTitle("Home")

    }

}


import SwiftUI

struct HomeView: View {
    
    // Access the shared BluetoothManager instance
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.largeTitle)
                .padding()
            
            // Display connection status
            Text(bluetoothManager.isConnected ? "Status: Connected ✅" : "Status: Disconnected ❌")
                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                .padding(.bottom, 20)
            
            Divider()
            
            Text("Received Data History (\(bluetoothManager.receivedDataHistory.count) entries)")
                .font(.title2)
                .padding(.vertical)

            // 🎯 Display the data history in a scrolling list
            List {
                // Use .reversed() to show the newest data at the top of the list
                ForEach(bluetoothManager.receivedDataHistory.reversed(), id: \.self) { dataString in
                    Text(dataString)
                        .font(.body)
                }
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Home")
    }
}*/

//
//  HomeView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI
import Charts

// MARK: - Data Model
struct PressureData: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let z: Double
    let pressure: Double
}

// MARK: - Data Manager
@Observable
final class PressureDataManager {
    var dataPoints: [PressureData] = []
    private var timer: Timer?
    let goalPressure: Double = 50  // mmHg target pressure

    func startMockData() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }

            // Generate random (x, y, z) within bounds
            let x = Double.random(in: 0...10)
            let y = Double.random(in: 0...10)
            let z = Double.random(in: 0...10)

            // Generate pressure around the goal with some variation
            let p = goalPressure + Double.random(in: -15...15)

            let newPoint = PressureData(x: x, y: y, z: z, pressure: p)

            Task { @MainActor in
                self.dataPoints.append(newPoint)
                if self.dataPoints.count > 100 {
                    self.dataPoints.removeFirst()
                }
            }
        }
    }

    func stopMockData() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - View
struct HomeView: View {
    @State private var manager = PressureDataManager()
    @State private var pose: Chart3DPose = .default

    private func color(for pressure: Double) -> Color {
        let goal = manager.goalPressure
        let diff = abs(pressure - goal)

        if diff < 5 {
            return .green
        } else if diff == 5 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
       ScrollView {
            VStack(spacing: 30) {
                Text("Home ")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // MARK: - 3D Pressure Chart
                Chart3D(manager.dataPoints) { point in
                    PointMark(
                        x: .value("X", point.x),
                        y: .value("Y", point.y),
                        z: .value("Z", point.z)
                    )
                    .foregroundStyle(color(for: point.pressure))
                }
                .chart3DPose($pose)
                .chart3DCameraProjection(.perspective)
                .frame(height: 300)
                .padding()
                .cornerRadius(16)
                .shadow(radius: 4)

                Text("3D Pressure Distribution")
                    .font(.headline)
                    .padding(.bottom)
                
            }
            .padding(.horizontal)
        }
        .onAppear {
            manager.startMockData()
        }
        .onDisappear {
            manager.stopMockData()
        }
    }
}

#Preview {
    HomeView()
}


