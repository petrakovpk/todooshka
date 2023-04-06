//
//  UserAPIService.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//
import Foundation
import Alamofire
import RxAlamofire
import FirebaseAuth
import RxCocoa
import RxSwift

protocol HasUserAPIService {
  var userAPIService: UserAPIService { get }
}

class UserAPIService {
  
  func fetchUser(userUID: String) -> Observable<Author> {
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
        
        let urlString = APIConfig.baseURL + "/api/v1.0/user/\(userUID)"
        guard let url = URL(string: urlString) else {
          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
          return
        }
        
        RxAlamofire.requestJSON(.get, url, headers: headers)
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (response, json) in
            guard let authorData = json as? [String: Any] else {
              observer.onError(NSError(domain: "Invalid JSON", code: 500, userInfo: nil))
              return
            }
            
            do {
              let authorJson = try JSONSerialization.data(withJSONObject: authorData, options: [])
              let decoder = JSONDecoder()
              decoder.dateDecodingStrategy = .iso8601
              decoder.keyDecodingStrategy = .convertFromSnakeCase
              let author = try decoder.decode(Author.self, from: authorJson)
              observer.onNext(author)
              observer.onCompleted()
            } catch {
              observer.onError(NSError(domain: "JSON parsing error", code: 500, userInfo: nil))
            }
          }, onError: { error in
            observer.onError(error)
          })
      }
      
      return Disposables.create()
    }
  }
  
  func fetchUserTasks(userUID: String) -> Observable<[Task]> {
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
        
        let urlString = APIConfig.baseURL + "/api/v1.0/user/\(userUID)/tasks"
        guard let url = URL(string: urlString) else {
          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
          return
        }
        
        RxAlamofire.requestJSON(.get, url, headers: headers)
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (response, json) in
            guard let tasksData = json as? [[String: Any]] else {
              observer.onError(NSError(domain: "Invalid JSON", code: 500, userInfo: nil))
              return
            }
            
            do {
              let tasksJson = try JSONSerialization.data(withJSONObject: tasksData, options: [])
              let decoder = JSONDecoder()
              decoder.dateDecodingStrategy = .iso8601
              decoder.keyDecodingStrategy = .convertFromSnakeCase
              let tasks = try decoder.decode([Task].self, from: tasksJson)
              observer.onNext(tasks)
              observer.onCompleted()
            } catch {
              observer.onError(NSError(domain: "JSON parsing error", code: 500, userInfo: nil))
            }
          }, onError: { error in
            observer.onError(error)
          })
      }
      
      return Disposables.create()
    }
  }
  
  func fetchRecommendedTasks() -> Observable<[Task]> {
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
        
        let urlString = APIConfig.baseURL + "/api/v1.0/user/\(currentUser.uid)/recommended"
        guard let url = URL(string: urlString) else {
          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
          return
        }
        
        RxAlamofire.requestJSON(.get, url, headers: headers)
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (response, json) in
            guard let tasksData = json as? [[String: Any]] else {
              observer.onError(NSError(domain: "Invalid JSON", code: 500, userInfo: nil))
              return
            }
            
            do {
              let tasksJson = try JSONSerialization.data(withJSONObject: tasksData, options: [])
              let decoder = JSONDecoder()
              decoder.dateDecodingStrategy = .iso8601
              decoder.keyDecodingStrategy = .convertFromSnakeCase
              let tasks = try decoder.decode([Task].self, from: tasksJson)
              observer.onNext(tasks)
              observer.onCompleted()
            } catch {
              observer.onError(NSError(domain: "JSON parsing error", code: 500, userInfo: nil))
            }
          }, onError: { error in
            observer.onError(error)
          })
      }
      
      return Disposables.create()
    }
  }
  
  
  
  
  
  
}
