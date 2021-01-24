//
//  WireUpdateCategoryRequestBody.swift
//  FableSDKWireObjects
//
//  Created by Enrique Florencio on 7/11/20.
//

import Foundation
import AppFoundation

public struct WireUpdateCategoryRequestBody: Codable, InitializableWireObject {
    public let name: String?
    //public let subtitle: String?
}
