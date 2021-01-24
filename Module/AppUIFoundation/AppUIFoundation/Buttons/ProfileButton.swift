//
//  ProfileButton.swift
//  AppFoundation
//
//  Created by Saroj Tiwari on 6/17/20.
//

import UIKit
import SnapKit

public class ProfileButton: UIButton {
    
    private let picker = UIImagePickerController()
    
    private let presenter: UIViewController?
    
    lazy var shadowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "profile_icon_placeholder")
        return imageView
    }()
    
    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init(frame: .zero)
        configureSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        shadowImageView.layer.cornerRadius = self.frame.width/2.70
        shadowImageView.layer.masksToBounds = true
    }
    
    private func configureSelf(){
        self.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        configureShadowLayer()
        self.addSubview(shadowImageView)
        shadowImageView.translatesAutoresizingMaskIntoConstraints = false
        shadowImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureShadowLayer(){
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 15)
        layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1.01, b: 0, c: 0, d: 1, tx: 0, ty: 0))
        layer.masksToBounds = false
    }
    
    @objc func profileButtonTapped(){
        imageHandler(presenter: presenter)
    }
    
    @objc func imageHandler(presenter: UIViewController!){
        let alertController = UIAlertController(title: "Profile Picture", message: "Please select your profile picture", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] (action: UIAlertAction!) in
            self?.handleImageSelection(presenter: (self?.presenter)!, sourceType: UIImagePickerController.SourceType.photoLibrary)
        })
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {[weak self] (action: UIAlertAction!) in
            self?.handleImageSelection(presenter: (self?.presenter)!, sourceType: UIImagePickerController.SourceType.camera)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            presenter.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        presenter.present(alertController, animated: true, completion: nil)
    }
}

extension ProfileButton: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func handleImageSelection(presenter: UIViewController, sourceType: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            self.picker.delegate = self
            self.picker.allowsEditing = true
            self.picker.sourceType = sourceType
            self.presenter?.present(picker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImageFromPicker: UIImage? = {
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
                return editedImage
            } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                return originalImage
            }
            return nil
        }()
        self.shadowImageView.image = selectedImageFromPicker
        self.presenter?.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presenter?.dismiss(animated: true, completion: nil)
    }
}

