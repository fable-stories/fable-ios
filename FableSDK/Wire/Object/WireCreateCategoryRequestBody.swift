//
//  WireCategoryAddName.swift
//  FableSDKWireObjects
//
//  Created by Enrique Florencio on 7/2/20.
//

import Foundation
import AppFoundation

public struct WireCreateCategoryRequestBody: Codable, InitializableWireObject {
    public let name: String?
    
}
