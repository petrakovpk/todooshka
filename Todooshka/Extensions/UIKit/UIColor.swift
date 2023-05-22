//
//  UIColor.swift
//  Todooshka
//
//  Created by Pavel Petakov on 17.09.2022.
//

import RxDataSources
import UIKit

extension UIColor: IdentifiableType {
  public var identity: String { self.hexString }
}
