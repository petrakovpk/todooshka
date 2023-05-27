//
//  DeviceView+Codable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 25.05.2023.
//

import UIKit

extension DevicePublicationView: Codable {
  enum CodingKeys: String, CodingKey {
    case publicationUUID = "publicationUuid", deviceUUID = "deviceUuid"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    publicationUUID = try container.decode(UUID.self, forKey: .publicationUUID)
    deviceUUID = try container.decode(UUID.self, forKey: .deviceUUID)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(publicationUUID, forKey: .publicationUUID)
    try container.encode(deviceUUID, forKey: .deviceUUID)
  }
}
