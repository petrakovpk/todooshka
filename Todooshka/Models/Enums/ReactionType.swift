//
//  ReactionType.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.04.2023.
//

enum ReactionType: String {
    case upvote
    case downvote
}


extension ReactionType: Equatable {
//  static func == (lhs: ReactionType, rhs: ReactionType) -> Bool {
//    lhs.rawValue == rhs.rawValue
//  }
}
