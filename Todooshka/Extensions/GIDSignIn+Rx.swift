//
//  GIDSignIn+Rx.swift
//  Todooshka
//
//  Created by Pavel Petakov on 09.09.2022.
//

import GoogleSignIn
import RxSwift
import RxCocoa

extension Reactive where Base: GIDSignIn {
  public func signIn(with config: GIDConfiguration, presenting: UIViewController) -> Observable<Result<GIDGoogleUser, Error>> {
    return Observable.create { observer in
      self.base.signIn(with: config, presenting: presenting) { user, error in
        if let user = user {
          observer.onNext(.success(user))
          observer.onCompleted()
        } else if let error = error {
          observer.onNext(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
}
