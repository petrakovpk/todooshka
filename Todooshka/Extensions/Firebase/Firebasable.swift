//
//  Firebasable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.02.2023.
//
import Firebase

public protocol Firebasable {
  associatedtype D: DataSnapshot

  var identity: String { get }
  var data: [String: Any] { get }

  init?(dataSnapshot: D)
}
