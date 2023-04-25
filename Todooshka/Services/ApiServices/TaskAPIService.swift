//
//  TaskAPIService.swift
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

protocol HasTaskAPIService {
  var taskAPIService: TaskAPIService { get }
}

class TaskAPIService {
  
  func fetchTaskImage(taskID: UUID) -> Observable<UIImage?> {
    return Observable.create { [unowned self] observer in
      let urlString = APIConfig.urlForTaskImage(taskID: taskID)
      APIConfig.authorizedHeaders { headers in
        guard let headers = headers else {
          observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
          return
        }
        
        AF.request(urlString, method: .get, headers: headers)
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
  
  func updateTask(task: Task) -> Observable<Task> {
    return Observable.create { [unowned self] observer in
      let urlString = "\(APIConfig.baseURL)/task/\(task.uuid)"
      
      do {
        let jsonData = try JSONEncoder().encode(task)
        let parameters = try JSONSerialization.jsonObject(with: jsonData) as? Parameters
        
        APIConfig.authorizedHeaders { headers in
          guard let headers = headers else {
            observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
            return
          }
          RxAlamofire.requestData(.put, urlString, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .subscribe(onNext: { (response, data) in
              if 200..<300 ~= response.statusCode {
                do {
                  let updatedTask = try JSONDecoder().decode(Task.self, from: data)
                  observer.onNext(updatedTask)
                  observer.onCompleted()
                } catch {
                  observer.onError(error)
                }
              } else {
                observer.onError(NSError(domain: "Server error", code: response.statusCode, userInfo: nil))
              }
            }, onError: { error in
              observer.onError(error)
            })
        }
        return Disposables.create()
      } catch {
        observer.onError(error)
        return Disposables.create()
      }
    }
  }
  
  func updateTaskImage(taskID: UUID, imageData: Data) -> Observable<Void> {
    return Observable.create { [unowned self] observer in
      let urlString = APIConfig.urlForTaskImage(taskID: taskID)
      APIConfig.authorizedHeaders { headers in
        guard let headers = headers else {
          observer.onError(NSError(domain: "No headers available", code: 500, userInfo: nil))
          return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
          multipartFormData.append(imageData, withName: "image", fileName: "task_image.jpeg", mimeType: "image/jpeg")
        }, to: urlString, method: .put, headers: headers)
        .validate(statusCode: 200..<300)
        .response { (response: AFDataResponse<Data?>) in
          switch response.result {
          case .success:
            observer.onNext(())
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
