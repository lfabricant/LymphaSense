//
//  HomeView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//


import SwiftUI
import Charts
import CoreBluetooth

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
    @EnvironmentObject var bluetoothManager: BluetoothManager

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
                
                // MARK: - 2D Pressure Chart
                Text("2D Pressure Distribution")
                    .font(.headline)
                
                Chart(bluetoothManager.receivedDataHistory) { dataPoint in
                
                    PointMark(
                        // X-axis: Time from the timestamp
                        x: .value("Time", dataPoint.timestamp),
                        // Y-axis: Data point value (converted to Double)
                        
                        //y: .value("Value", dataPoint.value)
                        y: .value("Value",
                                  Int(dataPoint.value
                                              .trimmingCharacters(in: .whitespacesAndNewlines)) ?? -1)
                    )
                    .foregroundStyle(.blue) // Ensure the line has a clear color
                    
                }
                // 🎯 FIX: Adjust the Y-scale domain to cover the full 0-1000 range.
                .chartYScale(domain: 0...1000)
                //.chartXAxis { ... } // (Keep your existing axis settings here)
                .frame(height: 250) // (Keep your existing frame settings here)
                
                
                // MARK: - 3D Pressure Chart
                Text("3D Pressure Distribution")
                    .font(.headline)
                
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
