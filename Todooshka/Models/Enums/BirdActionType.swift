//
//  BirdActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.05.2022.
//

import Foundation

enum BirdActionType: Equatable {
  case Hide
  case Init
  case Sitting(style: BirdStyle, closed: Date)
}

