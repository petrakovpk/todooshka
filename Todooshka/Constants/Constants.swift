//
//  Constants.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.03.2022.
//

import UIKit
import CoreGraphics

struct Constants {
  struct Scene {
    static let k: CGFloat = UIScreen.main.bounds.width / UIImage(named: "день01")!.size.width
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.width * UIImage(named: "день01")!.size.height / UIImage(named: "день01")!.size.width
  }
}
