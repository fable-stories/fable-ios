//
//  ServiceProvider.swift
//  Interface
//
//  Created by Andrew Aquino on 8/16/19.
//

import Foundation

public protocol ServiceTypeProtocol {}
public protocol ServiceProtocol {}

public protocol ServiceProviderProtocol: class {
  associatedtype Service: ServiceTypeProtocol
  associatedtype Interface: InterfaceProtocol
  
  init(interface: Interface)
}
