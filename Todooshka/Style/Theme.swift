//
//  Theme.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 29.08.2021.
//

import UIKit
import RxSwift
import RxTheme

protocol Theme {
  var backgroundColor: UIColor { get }
  var textColor: UIColor { get }
}

struct LightTheme: Theme {
  let backgroundColor = UIColor.selago
  let textColor = UIColor.black
}

struct DarkTheme: Theme {
  let backgroundColor = UIColor.haiti
  let textColor = UIColor.white
}

enum ThemeType: ThemeProvider {
  case light, dark
  var associatedObject: Theme {
    switch self {
    case .light: return LightTheme()
    case .dark: return DarkTheme()
    }
  }
}

let themeService = ThemeType.service(initial: UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
func themed<T>(_ mapper: @escaping ((Theme) -> T)) -> ThemeAttribute<T> {
  return themeService.attribute(mapper)
}

