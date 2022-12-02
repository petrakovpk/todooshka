//
//  TDContentView.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.11.2022.
//

import Foundation
import UIKit

enum ContentViewType {
  case image
  case text
}

class TDContentView: UIView {
  
  // MARK: - Init
  init(type: ContentViewType) {
    super.init(frame: .zero)
    backgroundColor = .systemRed.withAlphaComponent(0.2)
    cornerRadius = 15
    
    // adding
    addSubviews([
      
    ])
    
    // type
    switch type {
    case .image:
      return
    case .text:
      return
    }
  }
  
  func configure(with text: String) {
    
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
