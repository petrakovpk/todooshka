//
//  Errors.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import Foundation

enum AppError: Error {
  case driverError
}

extension AppError {
  var domain: String {
    return "com.piu.todooshka"
  }
  
  var code: Int {
    switch self {
    case .driverError:
      return 15
    }
  }
  
  // Локализованное описание ошибки
  var errorDescription: String? {
    switch self {
    case .driverError:
      return NSLocalizedString("Driver error", comment: "Driver error")
   
    }
  }
}

extension AppError: LocalizedError {
  
}
