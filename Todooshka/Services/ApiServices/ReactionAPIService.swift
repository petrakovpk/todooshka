//
//  ReactionAPIService.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.04.2023.
//

import Foundation
import Alamofire
import RxAlamofire
import FirebaseAuth
import RxCocoa
import RxSwift

protocol HasReactionAPIService {
  var reactionAPIService: ReactionAPIService { get }
}

class ReactionAPIService {
//  
//  func fetchReaction(reactionUUID: UUID) -> Observable<Reaction> {
//    return Observable.create { observer in
//      guard let currentUser = Auth.auth().currentUser else {
//        observer.onError(NSError(domain: "Not logged in", code: 401, userInfo: nil))
//        return Disposables.create()
//      }
//      
//      APIConfig.authorizedHeaders { headers in
//        guard let headers = headers else {
//          observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
//          return
//        }
//        
//        let urlString = APIConfig.urlForReaction + "/\(reactionUUID.uuidString)"
//        guard let url = URL(string: urlString) else {
//          observer.onError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
//          return
//        }
//        
//        RxAlamofire.requestJSON(.get, url, headers: headers)
//          .observeOn(MainScheduler.instance)
//          .subscribe(onNext: { (response, json) in
//            guard let reactionData = json as? [String: Any] else {
//              observer.onError(NSError(domain: "Invalid JSON", code: 500, userInfo: nil))
//              return
//            }
//            
//            do {
//              let reactionJson = try JSONSerialization.data(withJSONObject: reactionData, options: [])
//              let decoder = JSONDecoder()
//              decoder.dateDecodingStrategy = .iso8601
//              decoder.keyDecodingStrategy = .convertFromSnakeCase
//              let reaction = try decoder.decode(Reaction.self, from: reactionJson)
//              observer.onNext(reaction)
//              observer.onCompleted()
//            } catch {
//              observer.onError(NSError(domain: "JSON parsing error", code: 500, userInfo: nil))
//            }
//          }, onError: { error in
//            observer.onError(error)
//          })
//      }
//      
//      return Disposables.create()
//    }
//  }
//  
//  func updateReaction(reaction: Reaction) -> Observable<Reaction> {
//    return Observable.create { [unowned self] observer in
//      let urlString = APIConfig.urlForReaction
//      
//      do {
//        let jsonData = try JSONEncoder().encode(reaction)
//        let parameters = try JSONSerialization.jsonObject(with: jsonData) as? Parameters
//        
//        APIConfig.authorizedHeaders { headers in
//          guard let headers = headers else {
//            observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
//            return
//          }
//          RxAlamofire.requestData(.put, urlString, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .subscribe(onNext: { (response, data) in
//              if 200..<300 ~= response.statusCode {
//                do {
//                  let updatedReaction = try JSONDecoder().decode(Reaction.self, from: data)
//                  observer.onNext(updatedReaction)
//                  observer.onCompleted()
//                } catch {
//                  observer.onError(error)
//                }
//              } else {
//                observer.onError(NSError(domain: "Server error", code: response.statusCode, userInfo: nil))
//              }
//            }, onError: { error in
//              observer.onError(error)
//            })
//        }
//        return Disposables.create()
//      } catch {
//        observer.onError(error)
//        return Disposables.create()
//      }
//    }
//  }
}
