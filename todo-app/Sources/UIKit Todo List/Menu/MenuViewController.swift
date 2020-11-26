//
//  MenuViewController.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 12.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MenuCoordinator: AnyObject {
    func closeButtonTapped()
}

final class MenuViewController: UIViewController {
    
    // MARK: - Constants
    private struct Constants {
        static let title = "Menu"
        static let closeButtonTitle = "Close"
        static let alertTitle = "Error"
        static let successTitle = "Success"
        static let alertButtonText = "Ok"
        static let unauthorizedTitle = "Sign In or Sign Up"
        static let authorizedTitle = "You are logged as \n"
        static let loginButtonText = "Login"
        static let logoutButtonText = "Logout"
        static let loadingTitle = "Processing"
    }
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let closeButton = UIBarButtonItem(title: Constants.closeButtonTitle,
                                              style: .plain,
                                              target: self,
                                              action: nil)
    
    // MARK: - Outlets
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var firstTextfield: UITextField!
    @IBOutlet weak private var secondTextfield: UITextField!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var registerButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak private var syncStateContainer: UIStackView!
    @IBOutlet weak private var uploadStateButton: UIButton!
    @IBOutlet weak private var downloadStateButton: UIButton!
    
    // MARK: - Internal properties
    weak var coordinator: MenuCoordinator?
    var viewModel: MenuViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.willAppearEvent()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        title = Constants.title
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupBinding() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.closeButtonTapped()
            }).disposed(by: disposeBag)
        
        (firstTextfield.rx.text <-> viewModel.firstField).disposed(by: disposeBag)
        (secondTextfield.rx.text <-> viewModel.secondField).disposed(by: disposeBag)
        
        loginButton.rx.tap.subscribe { [weak self] _ in
            self?.viewModel.handleLoginEvent()
        }.disposed(by: disposeBag)
        
        registerButton.rx.tap.subscribe { [weak self] _ in
            self?.viewModel.registerEvent()
        }.disposed(by: disposeBag)
        
        uploadStateButton.rx.tap.subscribe { [weak self] _ in
            self?.viewModel.uploadEvent()
        }.disposed(by: disposeBag)
        
        downloadStateButton.rx.tap.subscribe { [weak self] _ in
            self?.viewModel.downloadEvent()
        }.disposed(by: disposeBag)
        
        viewModel.errorSubject
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(with: error)
            }).disposed(by: disposeBag)
        
        viewModel.successSubject
            .subscribe(onNext: { [weak self] error in
                self?.showSuccess(with: error)
            }).disposed(by: disposeBag)
        
        viewModel.state
            .subscribe(onNext: {[weak self] state in
                self?.handleState(state: state)
            }).disposed(by: disposeBag)
    }
    
    private func showAlert(with message: String) {
        let alertVC = UIAlertController(title: Constants.alertTitle,
                                        message: message,
                                        preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.alertButtonText,
                                         style: .default,
                                         handler: nil)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func showSuccess(with message: String?) {
        let alertVC = UIAlertController(title: Constants.successTitle,
                                        message: message,
                                        preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.alertButtonText,
                                         style: .default,
                                         handler: nil)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func handleState(state: MenuViewModel.State) {
        switch state {
        case .authorized(let email):
            titleLabel.text = Constants.authorizedTitle + email
            firstTextfield.isHidden = true
            secondTextfield.isHidden = true
            loginButton.setTitle(Constants.logoutButtonText, for: .normal)
            loginButton.isHidden = false
            activityIndicator.isHidden = true
            registerButton.isHidden = true
            syncStateContainer.isHidden = false
        case .loading:
            titleLabel.text = Constants.loadingTitle
            firstTextfield.isHidden = true
            secondTextfield.isHidden = true
            loginButton.isHidden = true
            activityIndicator.isHidden = false
            registerButton.isHidden = true
            syncStateContainer.isHidden = true
        case .unauthorized:
            titleLabel.text = Constants.unauthorizedTitle
            firstTextfield.isHidden = false
            secondTextfield.isHidden = false
            loginButton.setTitle(Constants.loginButtonText, for: .normal)
            loginButton.isHidden = false
            activityIndicator.isHidden = true
            registerButton.isHidden = false
            syncStateContainer.isHidden = true
        }
    }
}
