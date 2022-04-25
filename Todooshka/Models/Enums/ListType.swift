//
//  ListType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 31.03.2022.
//
import Foundation

enum ListType {
  case Completed(date: Date)
  case Deleted
  case Idea
  case Main
  case Overdued
}
