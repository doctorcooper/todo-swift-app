//
//  MenuViewModel.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 13.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

final class MenuViewModel {
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    
    @Keychain<String>(key: .token)
    private var token
    
    private struct Constants {
        static let loginErrorEmptyText = "Login must not be empty!"
        static let passwordErrorEmptyText = "Password must not be empty!"
    }
    
    // MARK: - Internal properties
    let state = BehaviorRelay<State>(value: .loading)
    
    let firstField = BehaviorRelay<String?>(value: nil)
    let secondField = BehaviorRelay<String?>(value: nil)
    
    let errorSubject = PublishSubject<String>()
    let successSubject = PublishSubject<String?>()
    
    var networkProvider: NetworkProvider!
    var repository: Repository!
    
    // MARK: - Internal methods
    func willAppearEvent() {
        checkState()
    }
    
    func handleLoginEvent() {
        switch state.value {
        case .authorized:
            logout()
        case .unauthorized:
            signIn()
        default: break
        }
    }
    
    func registerEvent() {
        guard let login = firstField.value, !login.isEmpty else {
            errorSubject.onNext(Constants.loginErrorEmptyText)
            return
        }
        guard let password = secondField.value, !password.isEmpty else {
            errorSubject.onNext(Constants.passwordErrorEmptyText)
            return
        }
        state.accept(.loading)
        networkProvider.register(login: login, password: password)
            .subscribe(onSuccess: { [weak self] token in
                self?.token = token
                self?.checkState()
                }, onError: {[weak self] error in
                    self?.errorSubject.onNext(error.localizedDescription)
                    self?.state.accept(.unauthorized)
            }).disposed(by: disposeBag)
    }
    
    func uploadEvent() {
        repository.getAll()
        let items = repository.output.map { TodoItemDTO(from: $0) }
        guard !items.isEmpty else { return }
        state.accept(.loading)
        networkProvider.uploadTask(items: items)
            .subscribe(onSuccess: { [weak self] _ in
                self?.successSubject.onNext("Uploaded \(items.count) items")
                self?.checkState()
            }, onError: { [weak self] error in
                self?.errorSubject.onNext(error.localizedDescription)
                self?.checkState()
            }).disposed(by: disposeBag)
    }
    
    func downloadEvent() {
        state.accept(.loading)
        networkProvider.getTasks()
            .subscribe(onSuccess: { [weak self] items in
                self?.repository.addItems(items: items)
                self?.successSubject.onNext("Downloaded \(items.count) items")
                self?.checkState()
            }, onError: { [weak self] error in
                self?.errorSubject.onNext(error.localizedDescription)
                self?.checkState()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    private func checkState() {
        networkProvider.getUser()
            .subscribe(onSuccess: { [weak self] email in
                self?.state.accept(.authorized(email: email))
            }, onError: { [weak self] _ in
                self?.state.accept(.unauthorized)
                self?.token = nil
            }).disposed(by: disposeBag)
    }
    
    private func signIn() {
        guard let login = firstField.value, !login.isEmpty else {
            errorSubject.onNext(Constants.loginErrorEmptyText)
            return
        }
        guard let password = secondField.value, !password.isEmpty else {
            errorSubject.onNext(Constants.passwordErrorEmptyText)
            return
        }
        state.accept(.loading)
        networkProvider.login(login: login, password: password)
            .subscribe(onSuccess: { [weak self] token in
                self?.token = token
                self?.checkState()
                }, onError: { [weak self] error in
                    self?.errorSubject.onNext(error.localizedDescription)
                    self?.state.accept(.unauthorized)
            }).disposed(by: disposeBag)
    }
    
    private func logout() {
        networkProvider.logout()
            .subscribe(onSuccess: { [weak self] _ in 
                self?.token = nil
                self?.checkState()
                }, onError: { [weak self] _ in
                    self?.token = nil
                    self?.checkState()
            }).disposed(by: disposeBag)
    }
}

extension MenuViewModel {
    enum State {
        case unauthorized
        case authorized(email: String)
        case loading
    }
}
