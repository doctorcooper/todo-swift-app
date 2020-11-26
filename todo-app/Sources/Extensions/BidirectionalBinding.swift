//
//  BidirectionalBinding.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 07.11.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//
import RxSwift
import RxCocoa

// From official example https://github.com/ReactiveX/RxSwift/blob/master/RxExample/RxExample/Operators.swift#L17
infix operator <-> : DefaultPrecedence

func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = relay.bind(to: property)
    let bindToRelay = property
        .subscribe(onNext: { n in
            relay.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToRelay)
}

