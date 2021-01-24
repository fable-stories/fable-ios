//
//  UIImage+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 8/24/19.
//

import UIKit

public extension UIImage {
  func resized(to targetSize: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { [weak self] (context) in
      self?.draw(in: CGRect(origin: .zero, size: targetSize))
    }
  }
  
  convenience init?(_ color: UIColor, size: CGSize) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    guard let cgImage = image.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
  
  func tinted(_ color: UIColor) -> UIImage {
    if #available(iOS 13.0, *) {
      return withTintColor(color, renderingMode: .alwaysOriginal)
    } else {
      return withRenderingMode(.alwaysTemplate).legacyTinted(color)
    }
  }
  
  private func legacyTinted(_ color: UIColor) -> UIImage {
    let maskImage = cgImage
    let bounds = CGRect(origin: .zero, size: size)
    return UIGraphicsImageRenderer(size: size).image { context in
      let cgContext = context.cgContext
      cgContext.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
      cgContext.clip(to: bounds, mask: maskImage!)
      color.setFill()
      cgContext.fill(bounds)
    }
  }
  
  func toCircularImage(size: CGSize) -> UIImage {
    // make a CGRect with the image's size
    let circleRect = CGRect(origin: .zero, size: size)
    
    // begin the image context since we're not in a drawRect:
    UIGraphicsBeginImageContextWithOptions(circleRect.size, false, 0)
    
    // create a UIBezierPath circle
    let circle = UIBezierPath(roundedRect: circleRect, cornerRadius: circleRect.size.width * 0.5)
    
    // clip to the circle
    circle.addClip()
    
    UIColor.white.set()
    circle.fill()
    
    // draw the image in the circleRect *AFTER* the context is clipped
    self.draw(in: circleRect)
    
    // get an image from the image context
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    
    // end the image context since we're not in a drawRect:
    UIGraphicsEndImageContext()
    
    return roundedImage ?? self
  }
}
