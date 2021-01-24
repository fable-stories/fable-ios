//
//  ImagePickerViewController.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 7/28/19.
//

import UIKit
import ReactiveSwift

public struct ImagePickerViewControllerBuilder {
  private static var delegateProxy: DelegateProxy?
  
  public enum Result {
    case cancelled
    case selected(UIImage)
  }
  
  public static func makeImagePickerAction() -> Action<UIViewController, ImagePickerViewControllerBuilder.Result, Never> {
    return Action { presenter in
      return SignalProducer { observer, _ in
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo", presenter: presenter, resultCallback: observer.send) {
          alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library", presenter: presenter, resultCallback: observer.send) {
          alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
          observer.sendCompleted()
        })
        
        presenter.present(alertController, animated: true, completion: nil)
      }.take(first: 1)
    }
  }
  
  public static func present(
    from presenter: UIViewController,
    resultCallback: @escaping (ImagePickerViewControllerBuilder.Result) -> Void
  ) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    if let action = self.action(for: .camera, title: "Take photo", presenter: presenter, resultCallback: resultCallback) {
      alertController.addAction(action)
    }
    if let action = self.action(for: .photoLibrary, title: "Photo library", presenter: presenter, resultCallback: resultCallback) {
      alertController.addAction(action)
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
      resultCallback(.cancelled)
    })

    presenter.present(alertController, animated: true, completion: nil)
  }
  
  private static func action(
    for sourceType: UIImagePickerController.SourceType,
    title: String,
    presenter: UIViewController,
    resultCallback: @escaping (ImagePickerViewControllerBuilder.Result) -> Void
  ) -> UIAlertAction? {
    guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return nil }
    return UIAlertAction(title: title, style: .default) { [weak presenter] _ in
      let vc = makeImagePickerVC(for: sourceType, resultCallback: resultCallback)
      presenter?.present(vc, animated: true, completion: nil)
    }
  }

  private static func makeImagePickerVC(
    for sourceType: UIImagePickerController.SourceType,
    resultCallback: @escaping (ImagePickerViewControllerBuilder.Result) -> Void
  ) -> UIViewController {
    let delegateProxy = DelegateProxy(resultCallback: resultCallback)
    ImagePickerViewControllerBuilder.delegateProxy = delegateProxy
    let vc = UIImagePickerController()
    vc.delegate = delegateProxy
    vc.allowsEditing = true
    vc.sourceType = sourceType
    vc.mediaTypes = ["public.image"]
    return vc
  }
  
  private class DelegateProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let resultCallback: (ImagePickerViewControllerBuilder.Result) -> Void
    
    public init(resultCallback: @escaping (ImagePickerViewControllerBuilder.Result) -> Void) {
      self.resultCallback = resultCallback
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
        imagePickerControllerDidCancel(picker)
        return
      }
      picker.dismiss(animated: true) { [weak self] in
        self?.resultCallback(.selected(image))
        ImagePickerViewControllerBuilder.delegateProxy = nil
      }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true) { [weak self] in
        self?.resultCallback(.cancelled)
        ImagePickerViewControllerBuilder.delegateProxy = nil
      }
    }
  }
}

