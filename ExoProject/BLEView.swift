//
//  BLEView.swift
//  ExoProject
//
//  Created by 이준녕 on 5/7/24.
//

import SwiftUI

struct BLEView: View {
    @StateObject var bluetoothManager = BluetoothManager()

    var body: some View {
        VStack {
//            Button("Scan for Devices") {
//                bluetoothManager.scan()
//            }
            
            Text(bluetoothManager.isSwitchedOn ? "ON" : "OFF")
            
            SensorConnectView(type: .BAND_L) {
                bluetoothManager.connectToSensor(type: .BAND_L)
            }
            
            SensorConnectView(type: .BAND_R) {
                bluetoothManager.connectToSensor(type: .BAND_R)
            }
            
            SensorConnectView(type: .SUIT) {
                bluetoothManager.connectToSensor(type: .SUIT)
            }
//            List(bluetoothManager.peripherals, id: \.identifier) { peripheral in
//                Text(peripheral.name ?? "Unknown")
//            }
            
//            Button("Connect to all devices") {
//                bluetoothManager.connectToPeripherals()
//            }
        }
    }
}


