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
    // different services for dif devices?
    static let DEVICE_SERVICE_UUID1 = "6E877C60-0E50-493F-B012-0A86ACF4610E"
    static let DEVICE_SERVICE_UUID2 = "6E877C60-0E50-493F-B012-1A86ACF4610E"
    static let DEVICE_SERVICE_UUID3 = "6E877C60-0E50-493F-B012-2A86ACF4610E"
    static let DEVICE_SERVICE_UUID = "6E877C60-0E50-493F-B012-3A86ACF4610E"
    
    static let notify = "6e877c62-0e50-493f-b012-3a86acf4610e" // Notify
    static let read = "6e877c62-0e50-493f-b012-3a86acf4610e" // Read
    static let write = "6e877c61-0e50-493f-b012-3a86acf4610e" // Write
    
    static let NOTIFY1 = "6e877c62-0e50-493f-b012-0a86acf4610e" // Notify
    static let READ1 = "6e877c62-0e50-493f-b012-0a86acf4610e" // Read
    static let WRITE1 = "6e877c61-0e50-493f-b012-0a86acf4610e" // Write
    
    static let NOTIFY2 = "6e877c62-0e50-493f-b012-1a86acf4610e" // Notify
    static let READ2 = "6e877c62-0e50-493f-b012-1a86acf4610e" // Read
    static let WRITE2 = "6e877c61-0e50-493f-b012-1a86acf4610e" // Write
    
    static let NOTIFY3 = "6e877c62-0e50-493f-b012-2a86acf4610e" // Notify
    static let READ3 = "6e877c62-0e50-493f-b012-2a86acf4610e" // Read
    static let WRITE3 = "6e877c61-0e50-493f-b012-2a86acf4610e" // Write
}

final class LittleBLE {
    static var shared = LittleBLE()
    var littleBT: LittleBlueTooth!
    var littleBT2: LittleBlueTooth!
    var littleBT3: LittleBlueTooth!
    
    init() {
        var littleBTConf = LittleBluetoothConfiguration()
        littleBTConf.autoconnectionHandler = { (perip, error) -> Bool in
            return true
        }
        littleBT = LittleBlueTooth(with: littleBTConf)
        littleBT2 = LittleBlueTooth(with: littleBTConf)
        littleBT3 = LittleBlueTooth(with: littleBTConf)
    }
}

struct DataAndTimeStamp: Codable {
    let date: Date
    let data: [Int16]
}

class BLEManager: ObservableObject {
    @Published var state = ""
    @Published var connected = false
    @Published var buttonIsEnabe: Bool = false
    @Published var text: String = "__"
    @Published var list: [UUID] = []
    @Published var discoveries: [PeripheralDiscovery] = []
    @Published var data: [[UInt8]] = [[]]
    
    @Published var band_L_data: [DataAndTimeStamp] = []
    @Published var band_R_data: [DataAndTimeStamp] = []
    @Published var suit_data: [DataAndTimeStamp] = []
    
    let notifyChar = LittleBlueToothCharacteristic(characteristic: HRMCostants.notify, for: HRMCostants.DEVICE_SERVICE_UUID, properties: .notify)
    let readChar = LittleBlueToothCharacteristic(characteristic: HRMCostants.read, for: HRMCostants.DEVICE_SERVICE_UUID, properties: .read)
    let writeChar = LittleBlueToothCharacteristic(characteristic: HRMCostants.write, for: HRMCostants.DEVICE_SERVICE_UUID, properties: .write)
    
    let notifyChar1 = LittleBlueToothCharacteristic(characteristic: HRMCostants.NOTIFY1, for: HRMCostants.DEVICE_SERVICE_UUID1, properties: .notify)
    let readChar1 = LittleBlueToothCharacteristic(characteristic: HRMCostants.READ1, for: HRMCostants.DEVICE_SERVICE_UUID1, properties: .read)
    let writeChar1 = LittleBlueToothCharacteristic(characteristic: HRMCostants.WRITE1, for: HRMCostants.DEVICE_SERVICE_UUID1, properties: .write)
    
    let notifyChar2 = LittleBlueToothCharacteristic(characteristic: HRMCostants.NOTIFY2, for: HRMCostants.DEVICE_SERVICE_UUID2, properties: .notify)
    let readChar2 = LittleBlueToothCharacteristic(characteristic: HRMCostants.READ2, for: HRMCostants.DEVICE_SERVICE_UUID2, properties: .read)
    let writeChar2 = LittleBlueToothCharacteristic(characteristic: HRMCostants.WRITE2, for: HRMCostants.DEVICE_SERVICE_UUID2, properties: .write)
    
    let notifyChar3 = LittleBlueToothCharacteristic(characteristic: HRMCostants.NOTIFY3, for: HRMCostants.DEVICE_SERVICE_UUID3, properties: .notify)
    let readChar3 = LittleBlueToothCharacteristic(characteristic: HRMCostants.READ3, for: HRMCostants.DEVICE_SERVICE_UUID3, properties: .read)
    let writeChar3 = LittleBlueToothCharacteristic(characteristic: HRMCostants.WRITE3, for: HRMCostants.DEVICE_SERVICE_UUID3, properties: .write)
    
    var littleBT = LittleBLE.shared.littleBT!
    var littleBT2 = LittleBLE.shared.littleBT2!
    var littleBT3 = LittleBLE.shared.littleBT3!
    
    var disposeBag = Set<AnyCancellable>()
//    var disposeBag2 = Set<AnyCancellable>()
    
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
            .collect(.byTime(RunLoop.main, .seconds(1)))
            .map{ (discoveries) -> [PeripheralDiscovery] in
                print("Discoveries: \(discoveries.map { $0.id } )")
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
                self.list = peripherals.map({ $0.id })
                self.discoveries = peripherals
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
                //                self.startListening()
                completion(true)
            })
            .store(in: &disposeBag)
        
    }
    
    func connect() {
        print("goes to connect")
        StartLittleBlueTooth
            .startDiscovery(for: self.littleBT, withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2)])
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
                //                self.startListening()
                
            }
            .store(in: &disposeBag)
        
//        StartLittleBlueTooth
//            .startListen(for: self.littleBT, from: notifyChar)
//            .sink(receiveCompletion: { (result) in
//                print("Result listening: \(result)")
//                switch result {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print("Error while trying to listen: \(error)")
//                }
//            }) { (value: readData) in
//                
//                //                self.text = String(value.list)
//            }
//            .store(in: &disposeBag)
    }
    
//    func startListening() {
//        print("trying to listen . .. ")
//        StartLittleBlueTooth
//            .startListen(for: self.littleBT, from: readChar2)
//            .sink(receiveCompletion: { (result) in
//                print("Result listening: \(result)")
//                switch result {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print("Error while trying to listen: \(error)")
//                }
//            }) { (value: readData) in
//                self.data.append(value.bytes)
//                print(value.bytes)
//                //                self.text = String(value.list)
//            }
//            .store(in: &disposeBag)
//    }
    
    func start() {
        StartLittleBlueTooth
            .write(for: littleBT, to: writeChar2, value: startCommand(), response: false)
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
    
    func stopAll() {
        StartLittleBlueTooth
            .write(for: littleBT, to: writeChar2, value: stopCommand(), response: false)
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
        
        StartLittleBlueTooth
            .write(for: littleBT2, to: writeChar3, value: stopCommand(), response: false)
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
        
        StartLittleBlueTooth
            .write(for: littleBT3, to: writeChar1, value: stopCommand(), response: false)
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
    
    func stop() {
        StartLittleBlueTooth
            .write(for: littleBT, to: writeChar2, value: stopCommand(), response: false)
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
    
    func stopDevice3() {
        StartLittleBlueTooth
            .write(for: littleBT2, to: writeChar3, value: stopCommand(), response: false)
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
    
    func startBandL() {
        littleBT.listenPublisher
            .filter { charact -> Bool in
                charact.id == self.readChar2.id
            }
            .tryMap { (characteristic) -> readBand in
                try characteristic.value()
            }.mapError { (error) -> LittleBluetoothError in
                if let er = error as? LittleBluetoothError {
                    return er
                }
                return .emptyData
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                self.band_L_data.append(DataAndTimeStamp(date: Date(), data: answer.list))
                print("BAND-L: \(answer)")
            }
            .store(in: &self.disposeBag)
        
        littleBT.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2)])
            .flatMap{ (discovery) -> AnyPublisher<PeripheralDiscovery, LittleBluetoothError> in
                       print("Discovery: \(discovery)")
                return self.littleBT.stopDiscovery().map { discovery }.eraseToAnyPublisher()
                   }
            .flatMap { discovery in
                self.littleBT.connect(to: discovery)
                    .write(for: self.littleBT, to: self.writeChar2, value: startCommand())
            }
            .flatMap { periph in
                self.littleBT.enableListen(from: self.readChar2)
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                print(answer)
            }
            .store(in: &disposeBag)
    }
    
    func startBandR() {
        littleBT2.listenPublisher
            .filter { charact -> Bool in
                charact.id == self.readChar3.id
            }
            .tryMap { (characteristic) -> readBand in
                try characteristic.value()
            }.mapError { (error) -> LittleBluetoothError in
                if let er = error as? LittleBluetoothError {
                    return er
                }
                return .emptyData
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                self.band_R_data.append(DataAndTimeStamp(date: Date(), data: answer.list))
                print("BAND-R: \(answer)")
            }
            .store(in: &self.disposeBag)
        
        littleBT2.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID3)])
            .flatMap{ (discovery) -> AnyPublisher<PeripheralDiscovery, LittleBluetoothError> in
                       print("Discovery: \(discovery)")
                return self.littleBT2.stopDiscovery().map { discovery }.eraseToAnyPublisher()
                   }
            .flatMap { discovery in
                self.littleBT2.connect(to: discovery)
                    .write(for: self.littleBT2, to: self.writeChar3, value: startCommand())
            }
            .flatMap { periph in
                self.littleBT2.enableListen(from: self.readChar3)
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                print(answer)
            }
            .store(in: &disposeBag)
    }
    
    func startSuit() {
        littleBT3.listenPublisher
            .filter { charact -> Bool in
                charact.id == self.readChar1.id
            }
            .tryMap { (characteristic) -> readData in
                try characteristic.value()
            }.mapError { (error) -> LittleBluetoothError in
                if let er = error as? LittleBluetoothError {
                    return er
                }
                return .emptyData
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                self.suit_data.append(DataAndTimeStamp(date: Date(), data: answer.list))
                print("SUIT: \(answer.list)")
            }
            .store(in: &self.disposeBag)
        
        littleBT3.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID1)])
            .flatMap{ (discovery) -> AnyPublisher<PeripheralDiscovery, LittleBluetoothError> in
                       print("Discovery: \(discovery)")
                return self.littleBT3.stopDiscovery().map { discovery }.eraseToAnyPublisher()
                   }
            .flatMap { discovery in
                self.littleBT3.connect(to: discovery)
                    .write(for: self.littleBT3, to: self.writeChar1, value: startCommand())
            }
            .flatMap { periph in
                self.littleBT3.enableListen(from: self.readChar1)
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                print(answer)
            }
            .store(in: &disposeBag)
    }
    
    func discoverMultiple() {
        littleBT.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID1), CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2), CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID3)])
            .collect(3)
            .map{ (discoveries) -> AnyPublisher<[PeripheralDiscovery], LittleBluetoothError> in
                        print("Discoveries: \(discoveries)")
                        return self.littleBT.stopDiscovery().map {discoveries}.eraseToAnyPublisher()
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
                    }, receiveValue: { (peripherals) in
                        print("Discovered Peripherals \(peripherals)")
                    })
            .store(in: &disposeBag)
    }
    
    func multipleListener() {
        // First publisher
//        littleBT.listenPublisher
//            .filter { charact -> Bool in
//                charact.id == self.readChar1.id
//            }
//            .tryMap { (characteristic) -> readData in
//                try characteristic.value()
//            }
//            .mapError { (error) -> LittleBluetoothError in
//                if let er = error as? LittleBluetoothError {
//                    return er
//                }
//                return .emptyData
//            }
//            .sink(receiveCompletion: { completion in
//                print("Completion \(completion)")
//            }) { (answer) in
//                print("Sub1: \(answer)")
//            }
//            .store(in: &self.disposeBag)
        
        // Second publisher
        littleBT.listenPublisher
            .filter { charact -> Bool in
                charact.id == self.readChar2.id
            }
            .tryMap { (characteristic) -> readData in
                try characteristic.value()
            }.mapError { (error) -> LittleBluetoothError in
                if let er = error as? LittleBluetoothError {
                    return er
                }
                return .emptyData
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                print("Sub2: \(answer)")
            }
            .store(in: &self.disposeBag)
        
//        // Third publisher
        littleBT.listenPublisher
            .filter { charact -> Bool in
                charact.id == self.readChar3.id
            }
            .tryMap { (characteristic) -> readData in
                try characteristic.value()
            }.mapError { (error) -> LittleBluetoothError in
                if let er = error as? LittleBluetoothError {
                    return er
                }
                return .emptyData
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                print("Sub3: \(answer)")
            } 
            .store(in: &self.disposeBag)
        
        func getProperWriteChar(disc: PeripheralDiscovery) -> LittleBlueToothCharacteristic {
            if let serviceUUIDs = disc.advertisement.serviceUUIDs {
                if serviceUUIDs.contains(where: { $0.uuidString == HRMCostants.DEVICE_SERVICE_UUID1 }) {
                    return writeChar1
                } else 
                if serviceUUIDs.contains(where: { $0.uuidString == HRMCostants.DEVICE_SERVICE_UUID2 }) {
                    print("here///2")
                    return writeChar2
                } else 
                if serviceUUIDs.contains(where: { $0.uuidString == HRMCostants.DEVICE_SERVICE_UUID3 }) {
                    print("here///3")
                    return writeChar3
                }
            }
            print("here///failed")
            return writeChar1
        }
        
        func getProperReadChar(disc: PeripheralDiscovery) -> LittleBlueToothCharacteristic {
            if let serviceUUIDs = disc.advertisement.serviceUUIDs {
                if serviceUUIDs.contains(where: { $0.uuidString == HRMCostants.DEVICE_SERVICE_UUID1 }) {
                    return readChar1
                } else
                if serviceUUIDs.contains(where: { $0.uuidString == HRMCostants.DEVICE_SERVICE_UUID2 }) {
                    return readChar2
                } else
                if serviceUUIDs.contains(where: { $0.uuidString == HRMCostants.DEVICE_SERVICE_UUID3 }) {
                    return readChar3
                }
            }
            print("here///failed")
            return readChar1
        }
        
        littleBT.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID3), CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2)])
//        littleBT.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID1)])
//            .collect(2)
//            .map{ (discoveries) -> AnyPublisher<[PeripheralDiscovery], LittleBluetoothError> in
//                        print("Discoveries: \(discoveries)")
//                        return self.littleBT.stopDiscovery().map {discoveries}.eraseToAnyPublisher()
//                    }
//            .sink(receiveCompletion: { result in
//                        print("Result: \(result)")
//                        switch result {
//                        case .finished:
//                            break
//                        case .failure(let error):
//                            // Handle errors
//                            print("Error: \(error)")
//                        }
//                    }, receiveValue: { (peripherals) in
//                        print("Discovered Peripherals \(peripherals)")
//                    })
//            .store(in: &disposeBag)
        
//            .map { discoveries in
//        for discovery in discoveries {
//                    self.littleBT.connect(to: discovery)
//                        .write(for: self.littleBT, to: getProperWriteChar(disc: discovery), value: startCommand())
//                        .flatMap { periph in
//                            self.littleBT.enableListen(from: getProperReadChar(disc: discovery))
//                        }
//                        .sink(receiveCompletion: { completion in
//                            print("Completion \(completion)")
//                        }) { (answer) in
//                            print(answer)
//                        }
//                        .store(in: &self.disposeBag)
//                    
//                }
//            }
//            .map{ (discoveries) -> AnyPublisher<[PeripheralDiscovery], LittleBluetoothError> in
//                        print("Discoveries: \(discoveries)")
//                        return self.littleBT.stopDiscovery().map {discoveries}.eraseToAnyPublisher()
//                    }
//            .map { disc -> PeripheralDiscovery in
//                print("Discovery discovery \(disc)")
//                return disc
//            }
            .flatMap { discovery in
                self.littleBT.connect(to: discovery)
                    .write(for: self.littleBT, to: getProperWriteChar(disc: discovery), value: startCommand())
            }
////            .flatMap { periph in
////                self.littleBT.enableListen(from: self.readChar1)
////            }
            .flatMap { periph in
                self.littleBT.enableListen(from: self.readChar2)
            }
            .flatMap { periph in
                self.littleBT.enableListen(from: self.readChar3)
            }
            .sink(receiveCompletion: { completion in
                print("Completion \(completion)")
            }) { (answer) in
                print(answer)
            }
            .store(in: &disposeBag)
        
//        littleBT.startDiscovery(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2)])
//            .map { disc -> PeripheralDiscovery in
//                print("Discovery discovery \(disc)")
//                return disc
//            }
//            .flatMap { discovery in
//                self.littleBT.connect(to: discovery)
//                    .write(for: self.littleBT, to: getProperWriteChar(disc: discovery), value: startCommand())
//            }
//            .flatMap { periph in
//                self.littleBT.enableListen(from: self.readChar2)
//            }
//            .sink(receiveCompletion: { completion in
//                print("Completion \(completion)")
//            }) { (answer) in
//                print(answer)
//            }
//            .store(in: &disposeBag2)
    }
}

struct startCommand: Writable {
    func createGetWiFiListCommand() -> [UInt8] {
        var payload = [UInt8]();
        payload.append(18);
        payload.append(0x00);
        payload.append(0x00);
        return payload;
    }
    
    var data: Data {
        return Data(createGetWiFiListCommand())
    }
}

struct stopCommand: Writable {
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

struct readBand: Readable {
    var list: [Int16]
//    var bytes: [UInt8]
    
    init(from data: Data) throws {
        var newArr = [UInt8]()
        
        for i in 2..<data.count {
            newArr.append(data[i])
        }
        
//        bytes = [UInt8](newArr)
        list = convertBytesToInt(newArr: newArr)
    }
}

struct readData: Readable {
    var list: [Int16]
//    var bytes: [UInt8]
    
    init(from data: Data) throws {
        var newArr = [UInt8]()
        
        for i in 2..<data.count {
//            if data[i] != 0 {
                newArr.append(data[i])
//            }
        }
//        bytes = [UInt8](newArr)
//            print(bytesToString(data: [UInt8](data)))
        var uint16Array: [Int16] = []
        for i in stride(from: 0, to: newArr.count, by: 2) {
//            let byte1 = UInt16(newArr[i])
//            let byte2 = i + 1 < newArr.count ? UInt16(newArr[i + 1]) : 0
//            let combined = byte2 << 8 | byte1
            let byte1 = newArr[i]
            let byte2 = newArr[i + 1]
            let combined = byte1 << 8 | byte2
            uint16Array.append(Int16(combined))
        }
list = uint16Array
//        print("uint16Array: \(uint16Array)")
//        print("count: \(uint16Array.count)")
//        print(String(utf16CodeUnits: uint16Array, count: uint16Array.count))
        if let string = String(bytes: newArr, encoding: .utf8) {
//            print("UTF8: \(string)")
        }
            
    }
    
}

struct readAndConvertData: Readable {
    init(from data: Data) throws {
        var newArr = [UInt8]()
        
        //        guard data.count > 1 else { return "" }
        
        for i in 2..<data.count {
            //            if data[i] != 0 {
            newArr.append(data[i])
        }
        var uint16Array: [Int16] = []
        for i in stride(from: 0, to: newArr.count, by: 2) {
//            let byte1 = UInt16(newArr[i])
//            let byte2 = i + 1 < newArr.count ? UInt16(newArr[i + 1]) : 0
//            let combined = byte2 << 8 | byte1
            let byte1 = newArr[i]
            let byte2 = newArr[i + 1]
            var combined: Int32 = Int32(UInt32(byte1) * 256 + UInt32(byte2))
            if (combined > 32768) {
                combined = combined-65536
            }
            uint16Array.append(Int16(combined))
        }
    }
}

func convertBytesToInt(newArr: [UInt8]) -> [Int16] {
    var uint16Array: [Int16] = []
    for i in stride(from: 0, to: newArr.count, by: 2) {
//            let byte1 = UInt16(newArr[i])
//            let byte2 = i + 1 < newArr.count ? UInt16(newArr[i + 1]) : 0
//            let combined = byte2 << 8 | byte1
        let byte1 = newArr[i]
        let byte2 = newArr[i + 1]
        var combined: Int32 = Int32(UInt32(byte1) * 256 + UInt32(byte2))
        if (combined > 32768) {
            combined = combined-65536
        }
        uint16Array.append(Int16(combined))
    }
    return uint16Array
}

//func bytesToString(data: [UInt8]) -> String {
////  print(data)
////  print(data.count)
//  var newArr = [UInt8]()
//    
//    guard data.count > 1 else { return "" }
//    
//  for i in 2..<data.count {
//      if data[i] != 0 {
//          newArr.append(data[i])
//      }
//  }
//    print(newArr)
//  if let string = String(bytes: newArr, encoding: .utf8) {
//      print(string)
//      return string
//  } else {
//      return "wrong format"
//  }
////    return newArr.description


func bytesToString(data: [UInt8]) -> String {
    var newArr = [UInt8]()

    guard data.count > 1 else { return "" }

    for i in 2..<data.count {
//        if data[i] != 0 {
            newArr.append(data[i])
//        }
    }
//    print("newArr:")
//    print(newArr)
    
    if let string = String(bytes: newArr, encoding: .utf8) {
//        print("from bytesToString: \(string)")
        return string
    } else {
//        print("sdfsdfsd")
        return ""
    }
}
