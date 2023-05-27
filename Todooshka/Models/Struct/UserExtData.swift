//
//  UserExtData.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//

import FirebaseAuth
import UIKit

struct UserExtData {
  let uid: String
  var nickname: String?
  var image: UIImage?
}

extension UserExtData: Equatable {

}
