//
//  TaskListMode.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 31.03.2022.
//
import Foundation

enum TaskListMode: Equatable {
  case tabBar
  case main
  case overdued
  case idea
  case day(date: Date)
  case calendar
  case deleted
  case userProfile
}
