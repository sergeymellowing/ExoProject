//
//  BluetoothManager.swift
//  ExoProject
//
//  Created by 이준녕 on 4/18/24.
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var isBluetoothEnabled = false
    @Published var discoveredPeripherals = [CBPeripheral]()

    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBluetoothEnabled = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            isBluetoothEnabled = false
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }

    func toggleBluetooth() {
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager = nil
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            UIApplication.openPhoneSettings { success in }
        }
    }
}


extension UIApplication {

    static func openAppSettings(completion: @escaping (_ isSuccess: Bool) -> ()) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completion(false)
            return
        }

        let app = UIApplication.shared

        app.open(url) { isSuccess in
            completion(isSuccess)
        }
    }

    static func openPhoneSettings(completion: @escaping (_ isSuccess: Bool) -> ()) {
        guard let url = URL(string: "App-Prefs:root=Bluetooth") else {
            completion(false)
            return
        }

        let app = UIApplication.shared

        app.open(url) { isSuccess in
            completion(isSuccess)
        }
    }

}
