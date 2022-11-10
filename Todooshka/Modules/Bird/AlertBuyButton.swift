//
//  AlertBuyButton.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.05.2022.
//

import UIKit

class AlertBuyButton: UIButton {
  override var isEnabled: Bool {
    didSet {
      backgroundColor = isEnabled ? Palette.SingleColors.Cerise : Palette.SingleColors.SantasGray
    }
  }
}
