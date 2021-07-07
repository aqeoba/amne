//
//  LoginViewController.swift
//  amne
//
//  Created by eternal on 06.07.2021.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.clipsToBounds = true
        return scrollview
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
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
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("ENTER", for: .normal)
        button.backgroundColor = .link
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
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        logField.delegate = self
        passField.delegate = self
        
        // add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(logField)
        scrollView.addSubview(passField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        logField.frame = CGRect(x: 30,
                                y: imageView.bottom + 10,
                                width: scrollView.width - 60,
                                height: 42)
        
        passField.frame = CGRect(x: 30,
                                 y: logField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 42)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 42)
    }

    @objc private func loginButtonTapped() {
        
        logField.resignFirstResponder()
        passField.resignFirstResponder()
        
        guard let log = logField.text, let pass = passField.text,
              !log.isEmpty, !pass.isEmpty, pass.count >= 6 else {
                alertUserLognError()
                return
        }
        
        // firebase connection
        
        FirebaseAuth.Auth.auth().signIn(withEmail: log, password: pass,
                                        completion: { [weak self] authResult, error in
                                            guard let strongSelf = self else {
                                                return
                                            }
                                            guard let result = authResult, error ==  nil else {
                                                print("FAILED LOGIN FOR USER: \(log)")
                                                return
                                            }
                                            
                                            let user = result.user
                                            print("LOGGED USER: \(user)")
                                            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLognError() {
        let alert = UIAlertController(title: "WHOOPS", message: "INCORRECT LOGIN INFO", preferredStyle: .alert)
        
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

extension LoginViewController: UITextFieldDelegate {
    
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
