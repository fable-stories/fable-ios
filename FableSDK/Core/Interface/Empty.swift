
import UIKit

public protocol AssetProtocol {}

public extension AssetProtocol {
  func image() -> UIImage? { self as? UIImage }
  func url() -> URL? { self as? URL }
}
