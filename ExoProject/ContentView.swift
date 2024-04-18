//
//  ContentView.swift
//  ExoProject
//
//  Created by 이준녕 on 4/18/24.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    
    @State var firstDeviceConnected: Bool = false
    @State var secondDeviceConnected: Bool = false
    @State var thirdDeviceConnected: Bool = false
    @State var fourthDeviceConnected: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                            bluetoothManager.toggleBluetooth()
                        }) {
                    Text(bluetoothManager.isBluetoothEnabled ? "Turn Off Bluetooth" : "Turn On Bluetooth")
                                .padding()
                   }
                        
              Text("Bluetooth is \(bluetoothManager.isBluetoothEnabled ? "enabled" : "disabled")")
//                            .padding()
            
            
            HStack {
                CustomButton(title: "DEVICE 1", action: connectFirstDevice, isConnected: $firstDeviceConnected)
                CustomButton(title: "DEVICE 2", action: connectSecondDevice, isConnected: $secondDeviceConnected)
            }
            HStack {
                CustomButton(title: "DEVICE 3", action: connectThirdDevice, isConnected: $thirdDeviceConnected)
                CustomButton(title: "DEVICE 4", action: connectFourthDevice, isConnected: $fourthDeviceConnected)
            }
            
            Button(action: save) {
                Text("SAVE")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 55)
            }
            .buttonStyle(.bordered)
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    //TODO: add logic here
    private func connectFirstDevice() {
        firstDeviceConnected.toggle()
    }
    
    private func connectSecondDevice() {
        secondDeviceConnected.toggle()
    }
    
    private func connectThirdDevice() {
        thirdDeviceConnected.toggle()
    }
    
    private func connectFourthDevice() {
        fourthDeviceConnected.toggle()
    }
    //TODO: add logic here
    private func save() {
        
    }
}

struct CustomButton: View {
    let title: String
    let action: () -> Void
    @Binding var isConnected: Bool
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 15)
                .fill(isConnected ? Color.green : Color.gray.opacity(0.2))
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
//        .padding()
    }
}

#Preview {
    ContentView()
}
