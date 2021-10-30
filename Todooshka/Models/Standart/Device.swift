//
//  Device.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.10.2021.
//
import UIKit

class Device {
  
  static let width: CGFloat = 414
  static var widthRatio: CGFloat {
    return UIScreen.main.bounds.width / width
  }
  
  static let height: CGFloat = 896
  static var heightRatio: CGFloat {
    return UIScreen.main.bounds.height / height
  }
}

extension CGFloat {
  var adjusted: CGFloat {
    return self * Device.widthRatio
  }
  var superAdjusted: CGFloat {
    return self * Device.heightRatio
  }
}


extension Double {
  var adjusted: CGFloat {
    return CGFloat(self) * Device.widthRatio
  }
  var superAdjusted: CGFloat {
    return CGFloat(self) * Device.heightRatio
  }
}

extension Int {
  var adjusted: CGFloat {
    return CGFloat(self) * Device.widthRatio
  }
  var superAdjusted: CGFloat {
    return CGFloat(self) * Device.heightRatio
  }
}
