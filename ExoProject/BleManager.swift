//
//  BleManager.swift
//  ExoProject
//
//  Created by Sergey Li on 4/23/24.
//

import SwiftUI
import CoreBluetooth
import LittleBlueTooth
import Combine

enum HRMCostants {
    // TODO: PASS HERE PROPER CHARACTERISTICS FOR IOT DEVICES
    static let DEVICE_SERVICE_UUID = "6e877c60-0e50-493f-b012-3a86acf4610e"
    
    static let notify = "6e877c62-0e50-493f-b012-3a86acf4610e" // Notify
    static let read = "6e877c62-0e50-493f-b012-3a86acf4610e" // Read
    static let write = "6e877c61-0e50-493f-b012-3a86acf4610e" // Write
}

final class LittleBLE {
    static var shared = LittleBLE()
    var littleBT: LittleBlueTooth!
    
    init() {
        var littleBTConf = LittleBluetoothConfiguration()
        littleBTConf.autoconnectionHandler = { (perip, error) -> Bool in
            return true
        }
        littleBT = LittleBlueTooth(with: littleBTConf)
    }
}

class BLEManager: ObservableObject {
    @Published var state = ""
    @Published var connected = false
    @Published var buttonIsEnabe: Bool = false
    @Published var text: String = "__"
    @Published var list: [PeripheralDiscovery] = []
    
    let notifyChar = LittleBlueToothCharacteristic(characteristic: HRMCostants.notify, for: HRMCostants.DEVICE_SERVICE_UUID, properties: .notify)
    let readChar = LittleBlueToothCharacteristic(characteristic: HRMCostants.read, for: HRMCostants.DEVICE_SERVICE_UUID, properties: .read)
    let writeChar = LittleBlueToothCharacteristic(characteristic: HRMCostants.write, for: HRMCostants.DEVICE_SERVICE_UUID, properties: .write)
    
    var littleBT = LittleBLE.shared.littleBT!
    
    var disposeBag = Set<AnyCancellable>()
    
    func pressedConnect() {
        if connected {
            disconnect()
        } else {
            connect()
        }
    }
    
    func discover() {
        print("discovering...")
        StartLittleBlueTooth
            .startDiscovery(for: self.littleBT, withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID)])
                    .collect(10)
                    .map{ (discoveries) -> [PeripheralDiscovery] in
                        print("Discoveries: \(discoveries)")
                        return discoveries
//                        return self.littleBT.stopDiscovery().map { discoveries }
                    }
                    .sink(receiveCompletion: { result in
                        print("Result: \(result)")
                        switch result {
                        case .finished:
                            break
                        case .failure(let error):
                            // Handle errors
                            print("Error: \(error)")
                        }
                    }, receiveValue: { peripherals in
                        self.list = peripherals
                        print("Discovered Peripherals \(peripherals)")
                    })
                    .store(in: &disposeBag)
        
//        StartLittleBlueTooth
//            .startDiscovery(for: self.littleBT, withServices: [])
//            .prefix(4)
//            .sink(receiveCompletion: { result in
//                
//                print("Result: \(result)")
//                switch result {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print("Error trying to connect: \(error)")
//                }
//            }) { (periph) in
////                print("Periph from startDiscovering: \(periph)")
//                if let name = periph.name, !self.list.contains(name) {
//                    self.list.append(name)
//                }
//        }
//            .store(in: &disposeBag)
    }
    
    func connect(discovery: PeripheralDiscovery?, completion: @escaping (Bool) -> Void) {
        guard let discovery else {
            print("No Discovery!")
            completion(false)
            return
        }
        print("trying to connect to: \(discovery.name)")
        self.littleBT
            .connect(to: discovery)
            .sink(receiveCompletion: { result in
                print("Result: \(result)")
                switch result {
                case .finished:
                    completion(false)
                    break
                case .failure(let error):
                    print(error)
                    completion(false)
                    break
                    // Handle errors
                }
            }, receiveValue: { (periph) in
                print("Connected Peripheral \(periph)")
                completion(true)
            })
            .store(in: &disposeBag)
    }
    
    func connect() {
        print("goes to connect")
        StartLittleBlueTooth
            .startDiscovery(for: self.littleBT, withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID)])
            .prefix(1)
            .connect(for: self.littleBT)
            .sink(receiveCompletion: { result in
                print("Result: \(result)")
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("Error trying to connect: \(error)")
                }
            }) { (periph) in
                print("Periph from startDiscovering: \(periph)")
                self.buttonIsEnabe = true
                self.connected = true
                self.startListening()
        }
        .store(in: &disposeBag)
        
        StartLittleBlueTooth
            .startListen(for: self.littleBT, from: notifyChar)
            .sink(receiveCompletion: { (result) in
                    print("Result listening: \(result)")
                    switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error while trying to listen: \(error)")
                    }
            }) { (value: readWifi) in
                
                self.text = String(value.list)
            }
            .store(in: &disposeBag)
    }
    
    func startListening() {
        StartLittleBlueTooth
            .startListen(for: self.littleBT, from: notifyChar)
            .sink(receiveCompletion: { (result) in
                    print("Result listening: \(result)")
                    switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error while trying to listen: \(error)")
                    }
            }) { (value: readWifi) in
                
                self.text = String(value.list)
            }
            .store(in: &disposeBag)
    }
    
    func getWifiList() {
        StartLittleBlueTooth
            .write(for: littleBT, to: writeChar, value: GetWifiCommand(), response: false)
            .sink(receiveCompletion: { (result) in
                print("Writing result: \(result)")
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("Error while writing control point: \(error)")
                    break
                }
                
            }) {}
            .store(in: &disposeBag)
    }
    
    func disconnect() {
        StartLittleBlueTooth
            .disconnect(for: self.littleBT)
            .sink(receiveCompletion: { (result) in
                print("Result: \(result)")
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("Error trying to disconnect: \(error)")
                }
            }) { (_) in
                self.buttonIsEnabe = true
                self.connected = false
        }
        .store(in: &disposeBag)
    }
}

struct GetWifiCommand: Writable {
    func createGetWiFiListCommand() -> [UInt8] {
        var payload = [UInt8]();
        payload.append(19);
        payload.append(0x00);
        payload.append(0x00);
        return payload;
    }
    
    var data: Data {
        return Data(createGetWiFiListCommand())
    }
}

struct readWifi: Readable {

    init(from data: Data) throws {
//        let wifi = bytesToString(data: [UInt8](data))
//        if !wifi.isEmpty {
            list = bytesToString(data: [UInt8](data))
//        }
        
//        print("result?: \(result)")
    }
    var list: String
}

//func bytesToString(data: [UInt8]) -> String {
//    var newArr = [UInt8]()
//
//    guard data.count > 1 else { return "" }
//
//    for i in 2..<data.count {
//        if data[i] != 0 {
//            newArr.append(data[i])
//        }
//    }
//    if let string = String(bytes: newArr, encoding: .ascii) {
//        print("from bytesToString: \(string)")
//        return string
//    } else {
//        print("sdfsdfsd")
//        return ""
//    }
//}

func bytesToString(data: [UInt8]) -> String {
//  print(data)
//  print(data.count)
  var newArr = [UInt8]()
    
    guard data.count > 1 else { return "" }
    
  for i in 2..<data.count {
      if data[i] != 0 {
          newArr.append(data[i])
      }
  }
//  print(newArr)
//  print(newArr.count)
//  print(String(bytes: newArr, encoding: .ascii))
  if let string = String(bytes: newArr, encoding: .ascii) {
      print(string)
      return string
  } else {
      return ""
  }
}
