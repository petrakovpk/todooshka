//
//  Observable+User+APIManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 09.04.2023.
//

import FirebaseAuth
import RxCocoa
import RxSwift

extension UIDevice {
  func fetchRecommendedPublications() -> Observable<[Publication]> {
    NetworkManager.shared.performUnsafeFetchRequestArrayOfCodableObjects(endpoint: APIConfig.Device.urlForRecommendedPublications(deviceUUID: UIDevice.current.identifierForVendor!.uuidString)
      )
  }
}
