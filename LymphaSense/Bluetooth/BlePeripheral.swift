//
//  BlePeripheral.swift
//  LymphaSense
//
//  Created by Lindsay on 11/28/25.
//


//
//  BlePeripheral.swift
//  Basic Chat MVC
//
//  Created by Trevor Beaton on 2/14/21.
//

import Foundation
import CoreBluetooth

class BlePeripheral {
 static var connectedPeripheral: CBPeripheral?
 static var connectedService: CBService?
 static var connectedTXChar: CBCharacteristic?
 static var connectedRXChar: CBCharacteristic?
}
