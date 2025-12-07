//
//  DataView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI

struct DataView: View {
        
    @EnvironmentObject var bluetoothManager: BluetoothManager
        
    // Define a DateFormatter to make the timestamp readable
    private static var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            return formatter
    }()
     
     var body: some View {
         VStack {
             Text("Data")
                 .font(.largeTitle)
                 .fontWeight(.bold)
                 .padding(.bottom, 40)
             
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
                 /*// Use .reversed() to show the newest data at the top of the list
                  ForEach(bluetoothManager.receivedDataHistory.reversed(), id: \.self) { dataString in
                  Text(dataString)
                  .font(.body)
                  }*/
                 
                 ForEach(bluetoothManager.receivedDataHistory.reversed()) { dataPoint in
                     HStack {
                         // Display the Timestamp
                         Text(dataPoint.timestamp, formatter: DataView.dateFormatter)
                             .font(.caption)
                             .foregroundColor(.gray)
                         
                         Spacer()
                         
                         // Display the Value
                         Text(String(dataPoint.value))
                             .font(.body)
                             .fontWeight(.medium)
                     }
                 }
             }
             .listStyle(.plain)
             
             
             Spacer()
         }
         .padding()
         .navigationTitle("Data")
     }
}


struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
} 
