//
//  ContentView.swift
//  BeaconScan
//
//  Created by 古宮 伸久 on 2024/08/23.
//

import SwiftUI

struct ContentView: View {
    let bitLinker = BitLinker()

    var body: some View {
        VStack {
            Form {
                bitLinker.isMonitoring ? Text("Monitoring") : Text("Not Monitoring")
                bitLinker.isRanging ? Text("Ranging") : Text("Not Ranging")
                bitLinker.isInside ? Text("Inside") : Text("Outside")

                if let beacon = bitLinker.beacon {
                    Text("RSSI: \(beacon.rssi)")
                    Text("Proximity: \(beacon.proximity.description)")
                    Text("Distance: \(pow(10.0, Double((bitLinker.txPower - beacon.rssi)) / 20.0))")
                }
            }
            ScrollView {
                ForEach(bitLinker.logs.reversed(), id: \.self) {
                    Text($0)
                }
            }
        }
        .padding()
        .task {
            bitLinker.request()
        }
    }
}

#Preview {
    ContentView()
}
