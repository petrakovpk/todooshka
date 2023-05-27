//
//  NetworkManager+UnsafePut.swift
//  DragoDo
//
//  Created by Pavel Petakov on 25.05.2023.
//

import Alamofire
import FirebaseAuth
import RxSwift
import RxCocoa
import RxAlamofire

extension NetworkManager {
  public func performUnsafePutRequest<T: Codable>(endpoint: String, codableObject: T) -> Observable<Void> {
    return Observable.create { observer in
      
      guard let url = URL(string: endpoint) else {
        observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
        return Disposables.create()
      }
      
      do {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try encoder.encode(codableObject)
        let parameters = try JSONSerialization.jsonObject(with: jsonData) as? Parameters
        
        RxAlamofire.request(.put, url, parameters: parameters, encoding: JSONEncoding.default, headers: APIConfig.commonHeaders)
          .responseData()
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (response, data) in
            if response.statusCode == 200 {
              observer.onNext(())
              observer.onCompleted()
            } else {
              observer.onError(NSError(domain: "Request failed", code: response.statusCode, userInfo: nil))
            }
          }, onError: { error in
            observer.onError(error)
          })
        
        
      } catch {
        observer.onError(NSError(domain: "Encoding error", code: 500, userInfo: nil))
      }
      
      
      return Disposables.create()
    }
  }
}
