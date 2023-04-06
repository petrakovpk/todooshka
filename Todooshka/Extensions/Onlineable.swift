//
//  Onlineable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 16.03.2023.
//
import Foundation

public protocol Onlineable {
  var identity: String { get }
  var serverData: [String: Any] { get }

  init?(data: Data)
}
