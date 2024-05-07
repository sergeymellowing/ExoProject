//
//  BluetoothManager.swift
//  ExoProject
//
//  Created by 이준녕 on 5/7/24.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    var centralManager: CBCentralManager!
    @Published var peripherals: [CBPeripheral] = []
    @Published var isSwitchedOn = false
    @Published var sensors: [Sensor] = []
    
    struct Sensor {
        let peripheral: CBPeripheral
        let name: String
        let type: SensorType
        var isConnected: Bool
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
            // Scan for peripherals with specified services
//            self.scan()
        } else {
            isSwitchedOn = false
        }
    }
    
//    func scan() {
//        centralManager.scanForPeripherals(withServices: [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID1), CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2), CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID3)], options: nil)
//    }
//    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Add discovered peripheral to the list
//        sensors.append(Sensor(peripheral: peripheral, name: peripheral.name ?? "NoName", type: sensorType, isConnected: false))
//        if !peripherals.contains(peripheral) {
//            peripherals.append(peripheral)
//            central.connect(peripheral, options: nil)
//            self.connectToPeripherals()
//        }
    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheral.delegate = self
//        // Discover services of the connected peripheral
//        peripheral.discoverServices(nil)
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            for service in services {
//                // Discover characteristics for each service
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                // Handle discovered characteristics
//                print("Discovered characteristic: \(characteristic)")
//            }
//        }
//    }
    
    // Implement other delegate methods as needed
    
    func connectToPeripherals() {
        // Connect to all discovered peripherals
        for peripheral in peripherals {
            centralManager.connect(peripheral, options: nil)
        }
    }
    
   
    
    func connectToSensor(type: SensorType) {
        var serviceUUIDs: [CBUUID] = []
       
        switch type {
        case .SUIT:
            serviceUUIDs = [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID1)]
        case .BAND_L:
            serviceUUIDs = [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID2)]
        case .BAND_R:
            serviceUUIDs = [CBUUID(string: HRMCostants.DEVICE_SERVICE_UUID3)]
            
        }
       
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
    }
    
    
}
enum SensorType: String, CaseIterable {
    case SUIT
    case BAND_L
    case BAND_R
}
