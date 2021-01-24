import AppFoundation
import ReactiveFoundation
import NetworkFoundation
import UIKit

public protocol InterfaceProtocol: class {
  var uuid: String { get }
}

public class Interface<ServiceProviderType: ServiceProviderProtocol>: InterfaceProtocol {

  public let uuid: String

  public private(set) lazy var services: ServiceProviderType = ServiceProviderType(interface: self as! ServiceProviderType.Interface)

  public init(
    uuid: String? = nil
  ) {
    let uuid = uuid ?? UUID().uuidString
    self.uuid = uuid
  }
}
