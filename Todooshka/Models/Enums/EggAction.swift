//
//  EggAction.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

enum EggAction {
  case Create(egg: Egg, withAnimation: Bool)
  case Update(egg: Egg)
  case Remove(egg: Egg)
}
