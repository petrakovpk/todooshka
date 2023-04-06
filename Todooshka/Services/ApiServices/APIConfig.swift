//
//  APIConfig.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//
import Alamofire
import FirebaseAuth

struct APIConfig {
  static let baseURL = "http://127.0.0.1:5050"
  static let commonHeaders: HTTPHeaders = [
    "Content-Type": "application/json"
  ]
  
  static func urlForTaskImage(taskID: UUID) -> String {
    return "\(baseURL)/api/v1.0/task/\(taskID)/image"
  }
  
  static func authorizedHeaders(completion: @escaping (HTTPHeaders?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else {
      fatalError("No current user")
    }
    
    currentUser.getIDToken(completion: { token, error in
      if let error = error {
        print("Error getting ID token: \(error)")
        completion(nil)
        return
      }
      
      guard let token = token else {
        print("No ID token available")
        completion(nil)
        return
      }
      
      var headers: HTTPHeaders = APIConfig.commonHeaders
      headers.add(name: "Authorization", value: "Bearer \(token)")
      completion(headers)
    })
  }
}
