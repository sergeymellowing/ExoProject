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
    
    var body: some View {
        VStack {
            ScrollView {
                Button(action: {
//                    if let suit_data = UserDefaults.standard.data(forKey: "suit_data") {
//                        do {
//                            // Create JSON Decoder
//                            let decoder = JSONDecoder()
//                            print("-------------------------")
//                            print("SUIT DATA:")
//                            print(try decoder.decode([DataAndTimeStamp].self, from: suit_data))
//                        } catch {
//                            print("Unable to Decode Suit Data (\(error))")
//                        }
//                    }
//                    if let band_L_data = UserDefaults.standard.data(forKey: "band_L_data") {
//                        do {
//                            // Create JSON Decoder
//                            let decoder = JSONDecoder()
//                            print("-------------------------")
//                            print("BAND_L DATA:")
//                            print(try decoder.decode([DataAndTimeStamp].self, from: band_L_data))
//                        } catch {
//                            print("Unable to Decode band_L Data (\(error))")
//                        }
//                    }
//                    if let band_R_data = UserDefaults.standard.data(forKey: "band_R_data") {
//                        do {
//                            // Create JSON Decoder
//                            let decoder = JSONDecoder()
//                            print("-------------------------")
//                            print("BAND_R DATA:")
//                            print(try decoder.decode([DataAndTimeStamp].self, from: band_R_data))
//                        } catch {
//                            print("Unable to Decode band_R Data (\(error))")
//                        }
//                    }
                }) {
                    Text("PRINT DATA")
                }
                .padding(10)
                
                Button(action: {
                    bleManager.startBandL()
                    bleManager.startBandR()
                    bleManager.startSuit()
                }) {
                    Text("START ALL")
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: 45)
                }
                .buttonStyle(.bordered)
                .padding(5)
                .padding(.top, 20)
                
//                SensorConnectView(type: .BAND_L, action: bleManager.startBandL)
//                SensorConnectView(type: .BAND_R, action: bleManager.startBandR)
//                SensorConnectView(type: .SUIT, action: bleManager.startSuit)
                
    //            Button(action: { bleManager.connect() }) {
    //                Text("CONNECT")
    //                    .font(.title)
    //                    .frame(maxWidth: .infinity, maxHeight: 55)
    //            }
    //            .buttonStyle(.bordered)
    //            .padding(5)
    //
    //            Button(action: { bleManager.start() }) {
    //                Text("START")
    //                    .font(.title)
    //                    .frame(maxWidth: .infinity, maxHeight: 55)
    //            }
    //            .buttonStyle(.bordered)
    //            .padding(5)
    //
    //            Button(action: { bleManager.startListening() }) {
    //                Text("LISTEN")
    //                    .font(.title)
    //                    .frame(maxWidth: .infinity, maxHeight: 55)
    //            }
    //            .buttonStyle(.bordered)
    //            .padding(5)
    //
    //
                Button(action: { bleManager.stopAll() }) {
                    Text("STOP ALL")
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: 45)
                }
                .buttonStyle(.bordered)
                .padding(5)
                
//                Button(action: { bleManager.stopDevice3() }) {
//                    Text("STOP")
//                        .font(.title)
//                        .frame(maxWidth: .infinity, maxHeight: 55)
//                }
//                .buttonStyle(.bordered)
//                .padding(5)
    //
                
                Button(action: save) {
                    Text("SAVE")
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: 55)
                }
                .buttonStyle(.bordered)
                .padding(5)
            }
            
            Spacer()
        }
        .padding()
    }

    //TODO: save all peripherals to DB
    private func save() {
//        do {
            // Create JSON Encoder
//            let encoder = JSONEncoder()

            // Encode
//            let suit_data = try encoder.encode(self.bleManager.suit_data)
//            let band_L_data = try encoder.encode(self.bleManager.band_L_data)
//            let band_R_data = try encoder.encode(self.bleManager.band_R_data)

            // Write/Set Data
//            UserDefaults.standard.set(suit_data, forKey: "suit_data")
//            UserDefaults.standard.set(suit_data, forKey: "band_L_data")
//            UserDefaults.standard.set(suit_data, forKey: "band_R_data")
            
//            UserDefaults.standard.set((self.bleManager.suit_data), forKey: <#T##String#>)
//            print("data was successfully saved")
//        } catch {
//            print("Unable to Encode Array of Notes (\(error))")
//        }

//        UserDefaults.standard.setValue(self.bleManager.suit_data, forKey: "suit_data")
//        UserDefaults.standard.setValue(self.bleManager.band_L_data, forKey: "band_L_data")
//        UserDefaults.standard.setValue(self.bleManager.band_R_data, forKey: "band_R_data")
        self.saveDataAsJSON(data: bleManager.suit_data, type: .SUIT)
        self.saveDataAsJSON(data: bleManager.band_L_data, type: .BAND_L)
        self.saveDataAsJSON(data: bleManager.band_R_data, type: .BAND_R)
    }
    
    func saveDataAsJSON(data: [DataAndTimeStamp], type: SensorType) {
        
        // Convert data to JSON format
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(data)
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: Date())
            let name = "\(dateString)_\(type.rawValue)"
            
            // Define the file URL where you want to save the JSON data
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("\(name).json")
            
            // Write JSON data to the file
            try jsonData.write(to: fileURL)
            
            print("Data saved as JSON successfully.")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
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

struct SensorConnectView: View {
    var type: SensorType
    let action: () -> Void
    
    var body: some View {
        let image = {
            switch type {
            case .SUIT:
                "accessibility"
            case .BAND_L:
                "left.circle"
            case .BAND_R:
                "right.circle"
            }
        }()
        
        Button(action: action) {
            HStack {
                Image(systemName: image)
                    .font(.title2)
                Text(type.rawValue)
                    .textCase(.uppercase)
                    .font(.title2)
            }.frame(maxWidth: .infinity, maxHeight: 55)
        }
        .buttonStyle(.bordered)
        .padding(5)
    }
}
