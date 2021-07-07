//
//  RegisterViewController.swift
//  amne
//
//  Created by eternal on 06.07.2021.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.clipsToBounds = true
        return scrollview
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let logField: UITextField =  {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "LOGNAME..."
        
        field.leftView  = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let nicknameField: UITextField =  {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "UR NAME..."
        
        field.leftView  = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passField: UITextField =  {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "PASSWORD..."
        
        field.leftView  = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let regButton: UIButton = {
        let button = UIButton()
        button.setTitle("REG", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LOG IN"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "REG",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapReg))
        
        regButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        logField.delegate = self
        passField.delegate = self
        
        // add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nicknameField)
        scrollView.addSubview(logField)
        scrollView.addSubview(passField)
        scrollView.addSubview(regButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        // gesture.numberOfTouchesRequired =
        // gesture.numberOfTapsRequired = 1
        
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        imageView.layer.cornerRadius = imageView.width/2.0

        
        nicknameField.frame = CGRect(x: 30,
                                y: imageView.bottom + 10,
                                width: scrollView.width - 60,
                                height: 42)
        
        logField.frame = CGRect(x: 30,
                                y: nicknameField.bottom + 10,
                                width: scrollView.width - 60,
                                height: 42)
        
        passField.frame = CGRect(x: 30,
                                 y: logField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 42)
        
        regButton.frame = CGRect(x: 30,
                                   y: passField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 42)
    }

    @objc private func loginButtonTapped() {
        
        logField.resignFirstResponder()
        passField.resignFirstResponder()
        nicknameField.resignFirstResponder()
        
        guard let nickName = nicknameField.text,
              let log = logField.text,
              let pass = passField.text,
              !nickName.isEmpty,
              !log.isEmpty,
              !pass.isEmpty,
              pass.count >= 6 else {
                alertUserLognError()
                return
        }
        
        // firebase connection
        
        DataBaseManager.shared.userExistance(with: log, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            guard !exists else {
                strongSelf.alertUserLognError(message: "LOOKS LIKE USER ALREADY EXISTS")
                return
            }
        
        
        FirebaseAuth.Auth.auth().createUser(withEmail: log, password: pass,
                                            completion: { authResult, error in
                                                guard authResult != nil, error == nil else {
                                                    print("ERROR CREATING USER")
                                                    return
                                                }
                                                
                                                DataBaseManager.shared.insertUser(with: chatAppUser(nickName: nickName, logIn: log))
                                                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                            })
    })
}
    
    func alertUserLognError(message: String = "INCORRECT REG INFO") {
        let alert = UIAlertController(title: "WHOOPS",
                                      message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "DISMISS",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapReg() {
        let vc = RegisterViewController()
        vc.title = "SAY UR NAME"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == logField {
            passField.becomeFirstResponder()
        }
        else if textField == passField {
            loginButtonTapped()
        }
        
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "PROFILE PIC",
                                            message: "HOW WOULD U LIKE TO TAKE A PIC?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "CANCEL",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "TAKE PHOTO",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                    self?.presentCamera()
                                                
                                            } ))
        actionSheet.addAction(UIAlertAction(title: "CHOOSE PHOTO",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                            } ))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        else { return }
        
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
