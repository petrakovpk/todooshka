//
//  BirdActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.05.2022.
//

import Foundation

enum BirdActionType: Equatable {
  case create
  case hide
  case sitting(style: BirdStyle, closed: Date)
}
