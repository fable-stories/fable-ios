//
//  Texture+.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation
import AppFoundation
import Kingfisher
import AsyncDisplayKit

public extension ASImageNode {
  func setImage(url: URL?) {
    guard let url = url else {
      self.image = nil
      return
    }
    let key = url.absoluteStringByTrimmingQuery
    if ImageCache.default.isCached(forKey: key) {
      return ImageCache.default.retrieveImageInDiskCache(forKey: key) { [weak self] result in
        switch result {
        case .failure(let error):
          print(error)
        case .success(let image):
          if let image = image {
            ImageCache.default.store(image, forKey: key)
          }
          self?.image = image
        }
      }
    }
    
    ImageDownloader.default.downloadImage(with: url, completionHandler:  { [weak self] result in
      switch result {
      case .failure(let error):
        print(error)
      case .success(let result):
        let image = result.image
        if let data = image.pngData() {
          ImageCache.default.storeToDisk(data, forKey: key, expiration: .days(1), callbackQueue: .mainAsync)
        }
        self?.image = image
      }
    })
  }
  
  func addShadow() {
    shadowColor = UIColor.black.cgColor
    shadowOffset = .init(width: 0.0, height: 5.0)
    shadowRadius = 5.0
    shadowOpacity = 0.2
    clipsToBounds = false
  }
}

public func RoundedCornersModificationBlock(cornerRadius: CGFloat) -> (UIImage, ASPrimitiveTraitCollection) -> UIImage? {
  return { image, _ in
    var modifiedImage: UIImage?
    let rect = CGRect(origin: .zero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
    let maskPath = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: UIRectCorner.allCorners,
      cornerRadii: .sizeWithConstantDimensions(16.0)
    )
    maskPath.addClip()
    image.draw(in: rect)
    modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return modifiedImage
  }
}
