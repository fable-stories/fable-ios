//
//  ImageManager.swift
//  FableSDKInterface
//
//  Created by Andrew Aquino on 11/10/20.
//

import Foundation
import Kingfisher


public protocol ImageManager {
  func fetchImage(forKey key: String) -> UIImage?
  func storeImage(_ image: UIImage, forKey key: String)
}


public class ImageManagerImpl: ImageManager {
  
  public init() {
    
  }

  public func fetchImage(forKey key: String) -> UIImage? {
    ImageCache.default.retrieveImageInMemoryCache(forKey: key)
  }
  
  public func storeImage(_ image: UIImage, forKey key: String) {
    ImageCache.default.store(image, forKey: key)
  }
}
    
