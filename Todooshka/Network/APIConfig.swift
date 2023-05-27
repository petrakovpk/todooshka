//
//  APIConfig.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//
import Alamofire
import FirebaseAuth

struct APIConfig {
  static let baseURL = "http://127.0.0.1:7070/api/v1.0"
  static let commonHeaders: HTTPHeaders = [
    "Content-Type": "application/json"
  ]
  
  struct Device {
    static func urlForRecommendedPublications(deviceUUID: String) -> String {
      return "\(baseURL)/publication/get_unreacted_publications_for_device/\(deviceUUID)"
    }
  }
  
  struct DevicePublicationView {
    static func urlForDevicePublicationView() -> String {
      return "\(baseURL)/device_publication_view/"
    }
  }
  
  struct Publication {
    static func urlForUnsafeImage(publicationUUID: String) -> String {
      return "\(baseURL)/publication/\(publicationUUID)/image/unsafe/"
    }
  }
  
  struct Reaction {
    static func urlForUserPublicationReaction(reactionUUID: UUID) -> String {
      return "\(baseURL)/user_publication_reaction/\(reactionUUID)"
    }
  }
  
  struct User {
    static func urlForRecommendedPublications(userUID: String) -> String {
      return "\(baseURL)/publication/get_unreacted_publications_for_user/\(userUID)"
    }
  }
  
  struct UserPublicationView {
    static func urlForUserPublicationView() -> String {
      return "\(baseURL)/user_publication_view/"
    }
  }
  
  struct UserExtData {
    static func urlForUpdateUser(userUID: String) -> String {
      return "\(baseURL)/user/\(userUID)"
    }
  }
  
  static let urlForTask = "\(baseURL)/task"
  

  
  static func urlForTaskImage(taskID: UUID) -> String {
    return "\(baseURL)/task/\(taskID)/image"
  }
  
  static func urlForTaskReactions(taskID: UUID) -> String {
    return "\(baseURL)/task/\(taskID)/reactions"
  }
  
  static func urlForTaskReactionForCurrentUser(taskID: UUID) -> String {
    return "\(baseURL)/task/\(taskID)/current_user_reaction/"
  }
  
  static func urlForTaskUser(taskID: UUID) -> String {
    return "\(baseURL)/task/\(taskID)/user"
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
