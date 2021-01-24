//
//  GradientView.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 8/6/19.
//

import UIKit

public class GradientView: UIView {
  public struct ViewModel {
    public let color: UIColor
    public let point: CGPoint

    public init(color: UIColor, point: CGPoint) {
      self.color = color
      self.point = point
    }
  }
  
  private let gradient: CAGradientLayer = CAGradientLayer()
  private let startViewModel: GradientView.ViewModel
  private let endViewModel: GradientView.ViewModel
  
  public init(start: GradientView.ViewModel, end: GradientView.ViewModel, alpha: CGFloat = 1.0) {
    self.startViewModel = start
    self.endViewModel = end
    super.init(frame: .zero)
    self.alpha = alpha
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  public override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    gradient.frame = self.bounds
  }
  
  override public func draw(_ rect: CGRect) {
    gradient.frame = self.bounds
    gradient.colors = [endViewModel.color.cgColor, startViewModel.color.cgColor]
    gradient.startPoint = startViewModel.point
    gradient.endPoint = endViewModel.point
    if gradient.superlayer == nil {
      layer.insertSublayer(gradient, at: 0)
    }
  }
}
