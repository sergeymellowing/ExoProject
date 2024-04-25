//
//  ContentView.swift
//  ExoProject
//
//  Created by 이준녕 on 4/18/24.
//

import SwiftUI
import LittleBlueTooth
import Combine

struct ContentView: View {
    @StateObject var bleManager = BLEManager()
    
    @State var firstDeviceConnected: Bool = false
    @State var secondDeviceConnected: Bool = false
    @State var thirdDeviceConnected: Bool = false
    @State var fourthDeviceConnected: Bool = false
    
    @State var connectedDevices: [PeripheralDiscovery] = []
    
    @State var disposeBag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Button(action: bleManager.discover) {
                Text("START DISCOVER")
            }
            .padding()
            
            ScrollView {
                let names = bleManager.list.filter{ (($0.name?.isEmpty) != nil) }.map { $0.name ?? "noname" }
                let ids = bleManager.list.map { $0.id }
//                let adaptiveColumn = [
//                    GridItem(.flexible(minimum: 100, maximum: 200)),
//                    GridItem(.flexible(minimum: 100, maximum: 200))
//                    ]
//                LazyVGrid(columns: adaptiveColumn, spacing: 10) {
//                    ForEach(names, id: \.self) { name in
//                        Button(action: {
//                            // TODO: need refactoring
//                            bleManager.connect(discovery: bleManager.list.first(where: { $0.name == name })) { success in
//                                self.firstConnectedDevice = name
//                            }
//                        }) {
////                            VStack {
//                                Text(name)
//                                    .foregroundColor(.white)
////                            }.overlay(
////                                RoundedRectangle(cornerRadius: 15)
////                                    .fill(self.firstConnectedDevice == name ? Color.green.opacity(0.5) : Color.gray.opacity(0.2))
////                            )
//                            .frame(maxWidth: .infinity, maxHeight: 200)
//                            .frame(minHeight: 150)
//                            .background((self.firstConnectedDevice == name ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)))
//                            .clipShape(RoundedRectangle(cornerRadius: 15))
//                        }
//                    }
//                }
                
                ForEach(ids, id: \.self) { id in
                    Button(action: {
                        bleManager.connect(discovery: bleManager.list.first(where: { $0.id == id })) { success in
                            guard let peripheral = bleManager.list.first(where: { $0.id == id }) else { return }
                            print("trying to connect to: \(id)")
                            self.connectedDevices.append(peripheral)
                        }
                    }) {
                        Text(id.uuidString)
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background((self.connectedDevices.contains(where: { $0.id == id }) ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)))
                            .padding(10)
                    }
                }
            }
            
            Button(action: { bleManager.startListening() }) {
                Text("LISTEN")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 55)
            }
            .buttonStyle(.bordered)
            .padding()
            
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

    //TODO: save all peripherals to DB
    private func save() {
        print("save all peripherals to DB:")
        print(self.connectedDevices)
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

struct NewBleView: View {
    @StateObject var bleManager = BLEManager()
    
    var body: some View {
        VStack(spacing: 40) {
            Button(action: {
                bleManager.pressedConnect()
            }) {
                Text(bleManager.connected ? "DISCONNECT" : "CONNECT")
                    .font(.title)
            }
            
            Button(action: {
                bleManager.startListening()
            }) {
                Text("START LISTENING")
                    .font(.title)
            }
            
            Button(action: {
                bleManager.getWifiList()
            }) {
                Text("GET WIFI LIST")
                    .font(.title)
            }
        }
    }
}
