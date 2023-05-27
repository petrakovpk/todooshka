//
//  DeviceView+NetworkManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 25.05.2023.
//

import RxCocoa
import RxSwift

extension DevicePublicationView {
  func saveToServer() -> Observable<Void> {
    NetworkManager.shared
      .performUnsafePutRequest(
        endpoint: APIConfig.DevicePublicationView.urlForDevicePublicationView(),
        codableObject: self)
  }
}

