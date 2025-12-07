//
//  TrendsView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

// TrendsView.swift

import SwiftUI

struct TrendsView: View {
    // 1. Access the shared Bluetooth data history and connection status
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    // 2. State to track the currently selected date (defaults to today)
    @State private var selectedDate = Date()
    
    // Date formatter for display
    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
    
    // Computed property to filter data based on the selected date (This remains the same)
    private var filteredData: [BluetoothDataPoint] {
        return bluetoothManager.receivedDataHistory.filter { dataPoint in
            Calendar.current.isDate(dataPoint.timestamp, inSameDayAs: selectedDate)
        }.reversed()
    }

    // 🆕 NEW: Computed property for the highest recorded value
    private var dailyHigh: Double? {
        // If data exists, map all values and find the maximum
        return filteredData.map { $0.value }.max()
    }

    // 🆕 NEW: Computed property for the lowest recorded value
    private var dailyLow: Double? {
        // If data exists, map all values and find the minimum
        return filteredData.map { $0.value }.min()
    }

    var body: some View {
        VStack {
                Text("Trends")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                // --- Monthly Calendar Picker ---
                Section {
                    // Use DatePicker in 'Graphical' style for a full monthly calendar look
                    DatePicker("Select a Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden() // Hide the "Select a Date" label
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical, 5)
            
            
            // --- Data Display Section ---
            VStack(alignment: .leading) {
                Text("Data for \(selectedDate, style: .date)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                if filteredData.isEmpty {
                    Text("No data recorded on this date.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    
                    // --- Daily Summary (High and Low) ---
                    if let high = dailyHigh, let low = dailyLow {
                        VStack(spacing: 10) {
                            // Display Daily High
                            SummaryStatRow(label: "Daily High", value: high)
                            
                            // Display Daily Low
                            SummaryStatRow(label: "Daily Low", value: low)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        
                        Divider()
                    }
                    
                    // --- Latest and Earliest Measurements List ---
                    List {
                        // Find the first (latest) data point
                        if let latestDataPoint = filteredData.first {
                            DataSummaryRow(
                                label: "Latest Measurement:",
                                timestamp: latestDataPoint.timestamp,
                                value: latestDataPoint.value,
                                formatter: TrendsView.timeFormatter
                            )
                        }
                        
                        // Find the last (earliest) data point, only if there's more than one
                        if filteredData.count > 1, let earliestDataPoint = filteredData.last {
                            DataSummaryRow(
                                label: "Earliest Measurement:",
                                timestamp: earliestDataPoint.timestamp,
                                value: earliestDataPoint.value,
                                formatter: TrendsView.timeFormatter
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding([.top], 20)
    }
}

    // 🆕 NEW: Helper struct for displaying the High/Low stats
    private struct SummaryStatRow: View {
        let label: String
        let value: Double

        var body: some View {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(value)")
                    .font(.headline)
                    .foregroundColor(.blue) // Use a distinct color for statistics
            }
        }
}


struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        // 1. Execute setup code in a block before returning the view
        let mockManager = BluetoothManager()
        
        // Add some mock data for today and yesterday
        mockManager.receivedDataHistory = [
            // Today's Data
            BluetoothDataPoint(timestamp: Date().addingTimeInterval(-120), value: 1024),
            BluetoothDataPoint(timestamp: Date().addingTimeInterval(-60), value: 1030),
            // Yesterday's Data
            BluetoothDataPoint(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, value: 990)
        ]

        // 2. Explicitly return the view and inject the object
        return TrendsView()
            .environmentObject(mockManager)
    }
}

private struct DataSummaryRow: View {
    let label: String
    let timestamp: Date
    let value: Double
    let formatter: DateFormatter // Pass the formatter in

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(timestamp, formatter: formatter)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(value)")
                .font(.title3)
                .fontWeight(.heavy)
        }
    }
}
