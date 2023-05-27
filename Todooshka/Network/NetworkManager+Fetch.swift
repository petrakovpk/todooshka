//
//  NetworkManager+Get.swift
//  DragoDo
//
//  Created by Pavel Petakov on 24.05.2023.
//

import Alamofire
import FirebaseAuth
import RxSwift
import RxCocoa
import RxAlamofire

extension NetworkManager {
  public func performFetchRequestSingleCodableObject<T: Decodable>(endpoint: String) -> Observable<T?> {
    return Observable.create { observer in
      guard let currentUser = Auth.auth().currentUser else {
        observer.onError(NSError(domain: "Not logged in", code: 401, userInfo: nil))
        return Disposables.create()
      }
      
      APIConfig.authorizedHeaders { headers in
        guard let headers = headers else {
          observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
          return
        }
        
        guard let url = URL(string: endpoint) else {
          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
          return
        }
        
        RxAlamofire.requestJSON(.get, url, headers: headers)
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (response, json) in
            if json is NSNull {
              observer.onNext(nil)
              observer.onCompleted()
            } else {
              do {
                let jsonData: Data
                
                if let data = json as? [String: Any] {
                  jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                } else {
                  throw NSError(domain: "Invalid JSON", code: 500, userInfo: nil)
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: jsonData)
                observer.onNext(result)
                observer.onCompleted()
              } catch {
                observer.onError(error)
              }
            }
          }, onError: { error in
            observer.onError(error)
          })
      }
      
      return Disposables.create()
    }
  }
  
  public func performFetchRequestArrayOfCodableObjects<T: Decodable>(endpoint: String) -> Observable<[T]> {
    return Observable.create { observer in
      guard let currentUser = Auth.auth().currentUser else {
        observer.onError(NSError(domain: "Not logged in", code: 401, userInfo: nil))
        return Disposables.create()
      }
      
      APIConfig.authorizedHeaders { headers in
        guard let headers = headers else {
          observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
          return
        }
        
        guard let url = URL(string: endpoint) else {
          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
          return
        }
        
        RxAlamofire.requestJSON(.get, url, headers: headers)
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (response, json) in
            if json is NSNull {
              observer.onNext([])
              observer.onCompleted()
            } else {
              do {
                let jsonData: Data
                
                if let array = json as? [[String: Any]] {
                  jsonData = try JSONSerialization.data(withJSONObject: array, options: [])
                } else {
                  throw NSError(domain: "Invalid JSON", code: 500, userInfo: nil)
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode([T].self, from: jsonData)
                observer.onNext(result)
                observer.onCompleted()
              } catch {
                observer.onError(error)
              }
            }
          }, onError: { error in
            observer.onError(error)
          })
      }
      
      return Disposables.create()
    }
  }
  
  public func performFetchRequestSingleImage(endpoint: String) -> Observable<UIImage?> {
    return Observable.create { [unowned self] observer in
      
      APIConfig.authorizedHeaders { headers in
        guard let headers = headers else {
          observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
          return
        }
        
        guard let url = URL(string: endpoint) else {
          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
          return
        }
        
        AF.request(url, method: .get, headers: headers)
          .validate(statusCode: 200..<300)
          .responseData { (response: AFDataResponse<Data>) in
            switch response.result {
            case .success(let data):
              let image = UIImage(data: data)
              observer.onNext(image)
              observer.onCompleted()
            case .failure(let error):
              observer.onError(error)
            }
          }
      }
      return Disposables.create()
    }
  }
}
